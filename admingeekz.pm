#!/usr/local/cpanel/3rdparty/bin/perl
if ( !caller() ) {
    print "Content-type: text/plain\r\n\r\nThis script is not indended to be called directly.";
    exit();
}


sub check_file {
        my ($file,$owner) = @_;
	return if ! -e $file;
        return if ! -O $file and $owner ne "n";
        return $file;
}

sub exit_error {
        my ($error) = @_;
        print "<font color=red>$error</font>";
        exit;
}
sub loadfile {
       	my ($file) = @_;
       	my $file_data;
        return exit_error("Error reading file $file") if !check_file($file,"y");
        if (open my $file_fh, '<', $file) {
               	while (my $line = readline $file_fh) {
                        $file_data .= $line;
               	}
                close $file_fh;
        }
       	return $file_data;
}

sub savefile {
	my ($file, $contents) = @_;
	if (open my $file_fh, '>', $file) {
		print $file_fh $contents;
		close $file_fh;
		return "Sucess";
	}
	return;
}


sub displayfile {
        my ($file) = @_;
        my $config = loadfile($file);
        $config = Cpanel::Encoder::safe_html_encode_str($config);
        return <<"EOM";
<form action="apf-gui.cgi" method="POST">
<input type="hidden" name="action" value="saveconfig"></input>
<input type="hidden" name="filename" value="$file"></input>
<textarea name="config" cols="100" rows="60">
$config
</textarea>
<br />
<input type="submit" value="Save Changes">
</form>
EOM
}

sub restart_daemon {
	my ($daemon) = @_;
        print "Restarting $daemon";
        print "<pre>";
	system "/etc/init.d/$daemon", 'restart';
        print "</pre>";
        print "Restart of $daemon complete";
}

sub reload_daemon {
        my ($daemon) = @_;
        print "Reloading $daemon";
        print "<pre>";
        system "/etc/init.d/$daemon", 'reload';
        print "</pre>";
	print "Reload of $daemon complete";
}


1;

