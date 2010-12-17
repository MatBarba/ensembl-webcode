package EnsEMBL::Web::Component::UserData::MoreInput;

use strict;
use warnings;
no warnings "uninitialized";

use base qw(EnsEMBL::Web::Component::UserData);

sub _init {
  my $self = shift;
  $self->cacheable( 0 );
  $self->ajaxable(  0 );
}

sub caption {
  my $self = shift;
  return 'File Details';
}

sub content {
  my $self = shift;

  my $species = $self->object->param('species') || $self->object->data_species;
  my $form = $self->modal_form('more_input', $self->object->species_path($species) . "/UserData/UploadFeedback", {'wizard' => 1});

  $form->add_element(type => 'Hidden', name => 'code', value => $self->object->param('code'));
  $form->add_element(type => 'Hidden', name => 'species', value => $species);
  $form->add_element(type => 'Information', value => 'Your file format could not be identified - please select an option:');
  $form->add_element(type => 'DropDown', name => 'format', label => 'File format', select => 'select', values => $self->all_formats);

  return $form->render;
}

1;
