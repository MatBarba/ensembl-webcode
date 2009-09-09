package EnsEMBL::Web::Configuration::Regulation;

use strict;
use EnsEMBL::Web::Document::Panel::SpreadSheet;
use EnsEMBL::Web::Document::Panel::Information;
use EnsEMBL::Web::Document::Panel::Image;
use Data::Dumper;

use base qw(EnsEMBL::Web::Configuration);

sub set_default_action {
  my $self = shift;
  unless( ref $self->object ){
    $self->{_data}{default} = 'Details';
    return;
  }
  my $x = $self->object->availability || {};
  if( $x->{'regulation'} ) {
    $self->{_data}{default} = 'Details';
  }

}

sub global_context { return $_[0]->_global_context; }
sub ajax_content   { return $_[0]->_ajax_content;   }
sub local_context  { return $_[0]->_local_context;  }
sub local_tools    { return $_[0]->_local_tools;  }
sub content_panel  { return $_[0]->_content_panel;  }
sub context_panel  { return $_[0]->_context_panel;  }

sub populate_tree {
  my $self = shift;

  $self->create_node( 'Details', "Details",
    [qw(summary EnsEMBL::Web::Component::Regulation::FeatureDetails)],
    { 'availability' => 'regulation' , 'concise' => 'Feature in detail' }
  );
  $self->create_node( 'Context', "Context",
    [qw(summary EnsEMBL::Web::Component::Regulation::FeatureSummary)],
    { 'availability' => 'regulation' , 'concise' => 'Feature context' }
  );
  $self->create_node( 'Evidence', "Evidence",
    [qw(summary EnsEMBL::Web::Component::Regulation::Evidence)],
    { 'availability' => 'regulation' , 'concise' => 'Evidence' }
  );


}


sub ajax_zmenu {
  my $self = shift;
  my $obj  = $self->object;
  my $action = $obj->[1]{'_action'} || 'Details'; 

  if ($action =~ /RegFeature/){
    return $self->ajax_zmenu_reg_feature;
  } elsif ($action =~ /Regulation/){
    return $self->ajax_zmenu_regulation;
  } 
  return;
}

1;
