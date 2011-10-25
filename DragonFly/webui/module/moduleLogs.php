<?php
#-
# Copyright (c) 2008 Beat Gätzi <beat@chruetertee.ch>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/webui/module/moduleLogs.php,v 1.5.2.3 2009/02/01 13:32:16 beat Exp $
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleLogs extends module {

	function moduleLogs( $TinderboxDS, $modulePorts ) {
		$this->module( $TinderboxDS );
		$this->modulePorts = $modulePorts;
	}

	function markup_log( $build_id, $id ) {
		global $rootdir, $logdir;
		global $with_timer, $starttimer;

		$ports = $this->TinderboxDS->getAllPortsByPortID( $id );
		if ( ! $ports ) {
			$this->TinderboxDS->addError( "Unknown port id : " . htmlentities( $id ) );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		$build = $this->TinderboxDS->getBuildByName( $build_id );
		if ( ! $build ) {
			$this->TinderboxDS->addError( "Unknown build id : " . htmlentities( $build_id ) );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		foreach ( $ports as $port ) {
			if ( $port->getBuildID() == $build->getID() ) {
				$build_port = $port;
				break;
			}
		}

		list( $data ) = $this->modulePorts->get_list_data( $build_id, array( $build_port ) );

		$patterns = array();

		if ( $build_port->getLastStatus() == 'FAIL' ) {
			foreach ( $this->TinderboxDS->getAllPortFailPatterns() as $pattern ) {
				if ( $pattern->getExpr() != '.*' ) {
					$patterns[$pattern->getId()]['id']       = $pattern->getId();
					$patterns[$pattern->getId()]['tag']      = $pattern->getReason();
					$patterns[$pattern->getId()]['severity'] = 'error';
					$patterns[$pattern->getId()]['expr']     = '/' . addcslashes( $pattern->getExpr(), '/' ) . '/';
					$patterns[$pattern->getId()]['color']    = 'red';
					$patterns[$pattern->getId()]['counter']  = 0;
				}
			}
		} else {
			foreach( $this->TinderboxDS->getAllLogfilePatterns() as $pattern ) {
				$patterns[$pattern->getId()]['id']       = $pattern->getId();
				$patterns[$pattern->getId()]['tag']      = $pattern->getTag();
				$patterns[$pattern->getId()]['severity'] = $pattern->getSeverity();
				$patterns[$pattern->getId()]['expr']     = $pattern->getExpr();
				$patterns[$pattern->getId()]['color']    = $pattern->getColor();
				$patterns[$pattern->getId()]['counter']  = 0;
			}
		}

		$zext     = '.bz2';
		$log_file = $data['port_logfile_path'];
		$plaintxt = is_file( $log_file );
		$compress = is_file( $log_file . $zext );
		if ( !$plaintxt && !$compress ) {
			$this->TinderboxDS->addError( "File cannot be opened for reading: " . $data['port_logfile_path'] );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		if ($plaintxt) {
			$fname_plaintxt = realpath( $log_file );
			$mtime_plaintxt = filemtime( $log_file );
		}
		if ($compress) {
			$fname_compress = realpath( $log_file . $zext );
			$mtime_compress = filemtime( $log_file . $zext );
		}
		if ($compress && $plaintxt) {
			$log_compressed = $mtime_compress > $mtime_plaintxt;
		} else {
			$log_compressed = $compress && !$plaintxt;
		}
		$file_name = $log_compressed ? $fname_compress : $fname_plaintxt;

		if ( strpos( $file_name, $logdir ) !== 0 ) {
			$this->TinderboxDS->addError( "File " . $file_name . " not in log directory: " . $logdir );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		$breakdown = $log_compressed ? 
			$this->scan_compress ( $file_name, $patterns ) :
			$this->scan_plaintxt ( $file_name, $patterns );

		$this->template_assign( 'lines', $breakdown['lines'] );
		$this->template_assign( 'stats', $breakdown['stats'] );
		$this->template_assign( 'colors', $breakdown['colors'] );
		$this->template_assign( 'counts', $breakdown['counts'] );
		$this->template_assign( 'displaystats', $breakdown['displaystats'] );
		$this->template_assign( 'build', $build_id );
		$this->template_assign( 'id', $id );
		$this->template_assign( 'data', $data );

		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 )
			$elapsed_time = get_ui_elapsed_time( $starttimer );

		$this->template_assign( 'ui_elapsed_time', $elapsed_time );

		return $this->template_parse( 'display_markup_log.tpl' );
	}
	
	function scan_plaintxt ( $file_name, $patterns ) {
		$lines = array();
		$stats = array();
		$colors = array();
		$counts = array();
		$displaystats = array();

		$fh = fopen( $file_name, 'r' );

		for ( $lnr = 1; ! feof( $fh ); $lnr++ ) {
			$line = fgets( $fh );

			$lines[$lnr] = htmlentities( rtrim( $line ) );
			$colors[$lnr] = '';

			foreach ( $patterns as $pattern ) {
				if ( !preg_match( $pattern['expr'], $line ) )
					continue;

				$colors[$lnr] = $pattern['color'];

				if ( !isset( $stats[$pattern['severity']] ) ) {
					$stats[$pattern['severity']] = array();
					$counts[$pattern['severity']] = 0;
					$displaystats[$pattern['severity']] = true;
					if ( isset( $_COOKIE[$pattern['severity']] ) && $_COOKIE[$pattern['severity']] == '0' )
						$displaystats[$pattern['severity']] = false;
				}

				if ( !isset( $stats[$pattern['severity']][$pattern['tag']] ) )
					$stats[$pattern['severity']][$pattern['tag']] = array();

				$stats[$pattern['severity']][$pattern['tag']][] = $lnr;
				$counts[$pattern['severity']]++;
			}
		}
		fclose ( $fh );

		$displaystats['linenumber'] = true;
		if ( isset( $_COOKIE['linenumber'] ) && $_COOKIE['linenumber'] == '0' )
			$displaystats['linenumber'] = false;

		return array (
			'lines'        => $lines,
			'stats'        => $stats,
			'colors'       => $colors,
			'counts'       => $counts,
			'displaystats' => $displaystats
		);
	}

	function scan_compress ( $file_name, $patterns ) {
		$lines = array();
		$stats = array();
		$colors = array();
		$counts = array();
		$displaystats = array();

		$fh = bzopen( $file_name, 'r' );

		$advance = TRUE;
		$chunk = "";
		$lnr = 0;
		while ($advance) {
			$chunk .= bzread( $fh, 4096);
			$chunklines = explode ("\n", $chunk);
			$numLines = count($chunklines);
			if (feof( $fh )) {			
				$stopline = $numLines;
				$advance = FALSE;
			} else {
				$stopline = $numLines - 1;
				$chunk = $chunklines[$stopline];
			}
			
			for ($x = 0; $x < $stopline; $x++) {
				$lnr++;
				$line = $chunklines[$x];
		
				$lines[$lnr] = htmlentities( rtrim( $line ) );
				$colors[$lnr] = '';

				foreach ( $patterns as $pattern ) {
					if ( !preg_match( $pattern['expr'], $line ) )
						continue;

					$colors[$lnr] = $pattern['color'];

					if ( !isset( $stats[$pattern['severity']] ) ) {
						$stats[$pattern['severity']] = array();
						$counts[$pattern['severity']] = 0;
						$displaystats[$pattern['severity']] = true;
						if ( isset( $_COOKIE[$pattern['severity']] ) && $_COOKIE[$pattern['severity']] == '0' )
							$displaystats[$pattern['severity']] = false;
					}
					
					if ( !isset( $stats[$pattern['severity']][$pattern['tag']] ) )
						$stats[$pattern['severity']][$pattern['tag']] = array();

					$stats[$pattern['severity']][$pattern['tag']][] = $lnr;
					$counts[$pattern['severity']]++;
				}
			}
		}
		fclose ( $fh );

		$displaystats['linenumber'] = true;
		if ( isset( $_COOKIE['linenumber'] ) && $_COOKIE['linenumber'] == '0' )
			$displaystats['linenumber'] = false;

		return array (
			'lines'        => $lines,
			'stats'        => $stats,
			'colors'       => $colors,
			'counts'       => $counts,
			'displaystats' => $displaystats
		);
	}
}
?>
