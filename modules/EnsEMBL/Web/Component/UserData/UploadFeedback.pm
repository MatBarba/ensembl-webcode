package EnsEMBL::Web::Component::UserData::UploadFeedback;

use strict;
use warnings;
no warnings "uninitialized";

use base qw(EnsEMBL::Web::Component::UserData);

sub _init {
  my $self = shift;
  $self->cacheable(0);
  $self->ajaxable(0);
}

sub caption {
  return 'File Uploaded';
}

sub content {
  my $self   = shift;
  my $hub    = $self->hub;
  my $upload = $hub->session->get_data('code' => $hub->param('code'));
  my $html;

  if ($upload) {

    ## Set format from CGI if necessary
    my $format;
    if ($hub->param('format')) {
      $format = $hub->param('format');
      if ($format =~ /bedgraph/i) {
        $format = 'BED';
      }
      $upload->{'format'} = $format;
      $hub->session->set_data(%$upload);
    }
    else {
      $format = $upload->{'format'};
    }

    $html = '<p class="space-below">Thank you. Your file uploaded successfully</p><p class="space-below"><strong>File uploaded</strong>: '.$upload->{'name'}.' (';
    if ($format) {
      $html .= "$format file";
    }
    else {
      $html .= 'Unknown format';
    }
    if (my $species = $upload->{'species'}) {
      $species =~ s/_/ /;
      $html .= ", <em>$species</em>";
    }
    else {
      $html .= ', unknown species';
    }
    $html .= ')</p>';
  }
  else {
    $html = qq(Sorry, there was a problem uploading your file. Please try again.);
  }
  return $html;
}

1;
