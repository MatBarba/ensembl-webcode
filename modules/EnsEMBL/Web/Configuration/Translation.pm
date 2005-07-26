package EnsEMBL::Web::Configuration::Translation;

use strict;
use EnsEMBL::Web::Document::Panel::SpreadSheet;
use EnsEMBL::Web::Document::Panel::Information;

use EnsEMBL::Web::Configuration;

@EnsEMBL::Web::Configuration::Translation::ISA = qw( EnsEMBL::Web::Configuration );

## Function to configure protview

sub protview {
  my $self   = shift;
  my $obj    = $self->{object};
  my @common = (
    'object' => $obj,
    'params' => { 'db'     => $obj->get_db, 'peptide' => $obj->stable_id }
  );

  my $daspanel = new EnsEMBL::Web::Document::Panel::Information(
    'code'    => "dasinfo$self->{flag}",
    'caption' => 'Protein DAS Report', 
    @common,
    'object'  => $obj,
    'status'  => 'panel_das'
  );

  $daspanel->add_components(qw(
    das           EnsEMBL::Web::Component::Translation::das
  ));

  my $panel1 = new EnsEMBL::Web::Document::Panel::Information(
    'code'    => "info$self->{flag}",
    'caption' => 'Ensembl Protein Report', 
    'object'  => $obj
  );
  $panel1->add_form( $self->{page}, 'markup_up_seq', 'EnsEMBL::Web::Component::Translation::marked_up_seq_form' );
  $self->initialize_zmenu_javascript;
  $panel1->add_components(qw(
    name        EnsEMBL::Web::Component::Gene::name
    stable_id   EnsEMBL::Web::Component::Gene::stable_id
    information EnsEMBL::Web::Component::Translation::information
    location    EnsEMBL::Web::Component::Gene::location
    description EnsEMBL::Web::Component::Gene::description
    method      EnsEMBL::Web::Component::Gene::method
    interpro    EnsEMBL::Web::Component::Transcript::interpro
    family      EnsEMBL::Web::Component::Transcript::family
    image       EnsEMBL::Web::Component::Translation::image
    sequence    EnsEMBL::Web::Component::Translation::marked_up_seq
    statistics  EnsEMBL::Web::Component::Translation::pep_stats
  ));
  $self->{page}->content->add_panel( $panel1 );

  $self->{page}->content->add_panel( $daspanel );

  my $panel2 = new EnsEMBL::Web::Document::Panel::SpreadSheet( 
    'code'    => 'domain_panel',
    'caption' => 'Domains on '.$obj->stable_id,
    @common,
    'status'  => 'panel_domain'
  );
  $panel2->add_components( qw(domains EnsEMBL::Web::Component::Translation::domain_list) );
  $self->{page}->content->add_panel( $panel2 );

  my $panel2a = new EnsEMBL::Web::Document::Panel::SpreadSheet(
    'code'    => 'other_panel',
    'caption' => 'Other features on '.$obj->stable_id,
    @common,
    'status'  => 'panel_other'
  );
  $panel2a->add_components( qw(others EnsEMBL::Web::Component::Translation::other_feature_list) );
  $self->{page}->content->add_panel( $panel2a );

  my $panel3 = new EnsEMBL::Web::Document::Panel::SpreadSheet( 
    'code'    => 'variation_panel',
    'caption' => 'Variations on '.$obj->stable_id,
    @common,
    'status'  => 'panel_variation'
  );

  $panel3->add_components( qw(snp_list EnsEMBL::Web::Component::Translation::snp_list) );
  $self->{page}->content->add_panel( $panel3 );
  $self->{page}->set_title( 'Peptide Report for '.$obj->stable_id );
}

sub context_menu {
  my $self = shift;
  my $obj      = $self->{object};
  my $species  = $obj->species;
  my $q_string_g = sprintf( "db=%s;gene=%s" ,       $obj->get_db , $obj->gene->stable_id );
  my $q_string   = sprintf( "db=%s;peptide=%s" , $obj->get_db , $obj->stable_id );
  my $flag     = "gene$self->{flag}";
  $self->{page}->menu->add_block( $flag, 'bulleted', $obj->stable_id );
  if( $obj->get_db eq 'vega' ) {
    $self->add_entry( $flag,
      'text'  => "Jump to Vega",
      'icon'  => '/img/vegaicon.gif',
      'title' => 'Vega - Information about peptide '.$obj->stable_id.' in Vega',
      'href' => "http://vega.sanger.ac.uk/$species/protview?peptide=".$obj->stable_id );
  }

  $self->{page}->menu->add_entry( $flag, 'text' => "Gene info.",
                                  'href' => "/$species/geneview?$q_string_g" );
  $self->{page}->menu->add_entry( $flag, 'text' => "Gene splice site image",
                                  'href' => "/$species/genespliceview?$q_string_g" );
  $self->{page}->menu->add_entry( $flag, 'text' => "Gene variation info.",
                                  'href' => "/$species/genesnpview?$q_string_g" ) if $obj->species_defs->databases->{'ENSEMBL_VARIATION'};

  $self->{page}->menu->add_entry( $flag, 'text' => "Genomic sequence",
                                  'href' => "/$species/geneseqview?$q_string_g" );
  $self->{page}->menu->add_entry( $flag, 'text' => "Exon info.",
                                  'href' => "/$species/exonview?$q_string" );
  $self->{page}->menu->add_entry( $flag, 'text' => "Transcript info.",
                                  'href' => "/$species/transview?$q_string" );
  $self->{page}->menu->add_entry( $flag, 'text' => "Export data",
                                  'href' => "/$species/exportview?type1=peptide;anchor1=@{[$obj->stable_id]}" );
  $self->{page}->menu->add_entry( $flag, 'text' => 'Peptide info.',
                                  'href' => "/$species/protview?$q_string" );
}

1;
