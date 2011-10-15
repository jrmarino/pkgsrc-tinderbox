<?php
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# Copyright (c) 2008 Beat G�tzi <beat@chruetertee.ch>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
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
# $MCom: portstools/tinderbox/webui/core/LogfilePattern.php,v 1.2.2.1 2008/12/21 17:27:29 beat Exp $
#

require_once 'TinderObject.php';

class LogfilePattern extends TinderObject {

	function LogfilePattern( $argv = array() ) {
		$object_hash = array(
			'logfile_pattern_id'       => '',
			'logfile_pattern_tag'      => '',
			'logfile_pattern_severity' => '',
			'logfile_pattern_expr'     => '',
			'logfile_pattern_color'    => ''
		);

		$this->TinderObject( $object_hash, $argv );
	}

	function getId() {
		return $this->logfile_pattern_id;
	}

	function getTag() {
		return $this->logfile_pattern_tag;
	}

	function getSeverity() {
		return $this->logfile_pattern_severity;
	}

	function getExpr() {
		return $this->logfile_pattern_expr;
	}

	function getColor() {
		return $this->logfile_pattern_color;
	}
}
?>
