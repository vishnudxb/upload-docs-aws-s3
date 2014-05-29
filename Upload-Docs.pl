#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use File::Find ();
use DateTime;
my $dt = DateTime->now;
my $date = $dt->ymd;   # Retrieves date as a string in 'yyyy-mm-dd' format

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;
sub doexec ($@);

use Cwd ();
my $cwd = Cwd::cwd();


# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, '/uploads/server/documents');
File::Find::find({wanted => \&wanted_sec}, '/uploads/server/documents');
File::Find::find({wanted => \&wanted_third}, '/uploads/server/documents');
aws();
exit;


sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    /^I-CAE.*\z/s &&  
    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    (int(-M _) > 50) &&
    doexec(0, 'zip','-r','I-CAE-' . $date . '.zip','{}');
}

sub wanted_sec {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    /^I-CSA.*\z/s &&  
    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    (int(-M _) > 50) &&
    doexec(0, 'zip','-r','I-CSA-' . $date . '.zip','{}');
}

sub wanted_third {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    /^I-CME.*\z/s &&  
    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    (int(-M _) > 50) &&
    doexec(0, 'zip','-r','I-CME-' . $date . '.zip','{}');
}

sub doexec ($@) {
    my $ok = shift;
    my @command = @_; # copy so we don't try to s/// aliases to constants
    for my $word (@command)
        { $word =~ s#{}#$name#g }
    if ($ok) {
        my $old = select(STDOUT);
        $| = 1;
        print "@command";
        select($old);
        return 0 unless <STDIN> =~ /^y/;
    }
    chdir $cwd; #sigh
    system @command;
    print  $name;
    unlink $name;
    chdir $File::Find::dir;
    return !$?;
}


sub aws {
use Net::Amazon::S3;
  my $aws_access_key_id     = '< give the access key >';
  my $aws_secret_access_key = '< give the secret key >';
  my $aws_s3_endpoint       = '< give the endpoint location >';

  my $s3 = Net::Amazon::S3->new(
      {   aws_access_key_id     => $aws_access_key_id,
          aws_secret_access_key => $aws_secret_access_key,
          retry                 => 1,
      }
  );
  my $local_file = 'I-CAE-' . $date . '.zip';
  my $local_file_sec = 'I-CSA-' . $date . '.zip';
  my $local_file_third = 'I-CME-' . $date . '.zip';

  my $bucket_name = 'perl-backups';
  my $bucket_folder_name = 'perl-docs';
  my $bucket_inside_folder_name = 'perl-files';
  my $bucket = $s3->bucket($bucket_name);
  print "\nTransferring file $local_file to bucket $bucket_name...\n";
  STDOUT->flush();
  $bucket->add_key_filename($bucket_folder_name . '/'. $bucket_inside_folder_name . '/'. $local_file, $local_file, { content_type => 'application/zip' })
	|| die "Couldn't copy file to bucket: " . $s3->errstr . "\n";
  print "\nTransferring file $local_file_sec to bucket $bucket_name...\n";
  $bucket->add_key_filename($bucket_folder_name . '/'. $bucket_inside_folder_name . '/'. $local_file_sec, $local_file_sec, { content_type => 'application/zip' })
  || die "Couldn't copy file to bucket: " . $s3->errstr . "\n";
  print "\nTransferring file $local_file_third to bucket $bucket_name...\n";
  $bucket->add_key_filename($bucket_folder_name . '/'. $bucket_inside_folder_name . '/'. $local_file_third, $local_file_third, { content_type => 'application/zip' })
  || die "Couldn't copy file to bucket: " . $s3->errstr . "\n";
  print "Done!\n";
  print "Removing the $local_file files!!\n";
  unlink $local_file;  
  print "Removing the $local_file_sec  files!!\n";
  unlink $local_file_sec;  
  print "Removing the $local_file_third files!!\n";
  unlink $local_file_third;  
  exit 0; 
}

