package Bio::EnsEMBL::GlyphSet::fg_regulatory_features;
use strict;
use vars qw(@ISA);
use Bio::EnsEMBL::GlyphSet_simple;
use Bio::EnsEMBL::Utils::Eprof qw(eprof_start eprof_end eprof_dump);
@ISA = qw(Bio::EnsEMBL::GlyphSet_simple);
use Data::Dumper;

sub my_label { return "Reg. Features"; }

sub features {
  my ($self) = @_;
   my $slice = $self->{'container'};
  my $Config = $self->{'config'};
  my $type = $self->check();
 
  my $fg_db = undef;
  my $db_type  = $self->my_config('db_type')||'funcgen';
  unless($slice->isa("Bio::EnsEMBL::Compara::AlignSlice::Slice")) {
    $fg_db = $slice->adaptor->db->get_db_adaptor($db_type);
    if(!$fg_db) {
      warn("Cannot connect to $db_type db");
      return [];
    }
  }
  
  my $reg_features = $self->fetch_features($fg_db, $slice);
  
}

sub fetch_features {
  my ($self, $db, $slice ) = @_;
  unless ( exists( $self->{'config'}->{'reg_feats'} ) ){
    my $dsa = $db->get_FeatureSetAdaptor(); 
    if (!$dsa) {
      warn ("Cannot get get adaptors: $dsa");
      return [];
    }

    
  my @reg_feature_sets = @{$dsa->fetch_all_displayable_by_type('regulatory')};
    
  foreach my $set (@reg_feature_sets) { 
	 foreach my $pf (@{$set->get_Features_by_Slice($slice) }){
      my $type = $pf->feature_type->name();
      my $id  = $pf->stable_id; 
      my $label = $pf->display_label;
    }
    my @pf_ref = @{$set->get_Features_by_Slice($slice)};
    if(@pf_ref && !$self->{'config'}->{'fg_regulatory_features_legend_features'} ) {
      #warn "...................".ref($self)."........................";
      $self->{'config'}->{'fg_regulatory_features_legend_features'}->{'fg_reglatory_features'} = { 'priority' => 1020, 'legend' => [] };
    }
    $self->{'config'}->{'reg_feats'} = \@pf_ref;
  }  

  }
  my $reg_feats = $self->{'config'}->{'reg_feats'} || [];  
  if (@$reg_feats && $self->{'config'}->{'fg_regulatory_features_legend_features'} ){
    $self->{'config'}->{'fg_regulatory_features_legend_features'}->{'fg_regulatory_features'} = {'priority' =>1020, 'legend' => [] };	
  }
  return $reg_feats;
}



sub colour {
  my ($self, $f) = @_;
  my $type = $f->feature_type->name();
  if ($type =~/Promoter/){$type = 'Promoter_associated';}
  elsif ($type =~/Gene/){$type = 'Genic';}
  elsif ($type =~/Unclassified/){$type = 'Unclassified';}
  if ($type =~/Non/){$type = 'Non-genic';}
  unless ($self->{'config'}->{'reg_feat_type'}{$type}) {
   push @{$self->{'config'}->{'fg_regulatory_features_legend_features'}->{'fg_regulatory_features'}->{'legend'}},
    $self->{'colours'}{$type}[1], $self->{'colours'}{$type}[0];
    $self->{'config'}->{'reg_feat_type'}{$type}	= 1;
  }	
  return $self->{'colours'}{$type}[0],
  $self->{'colours'}{$type}[2],
  $f->start > $f->end ? 'invisible' : '';
}

sub zmenu {
  my ($self, $f) = @_; 
  my $stable_id = $f->stable_id;
  my @atts = @{$f->regulatory_attributes()}; 
  my $display_label = $f->display_label();
  my @temp = map $_->feature_type->name(), @atts;
  my %att_label;
  foreach my $k (@temp){ $att_label{$k} = "";}
  my @keys = keys %att_label;  
  my $label = join(', ', @keys);
  my $type = $f->feature_type->name();
  my ($start, $end) = $self->slice2sr($f->start, $f->end);
  my ($bstart, $bend) = $self->slice2sr($f->bound_start, $f->bound_end);
  #warn "$start, $end $bstart, $bend";
  my $zmenu = {
         qq(caption)       		=> qq($display_label),
         qq(01:Stable ID: $stable_id) => '',
         qq(02:Type: $type) =>'',
         qq(03:bp: $start-$end) =>'',    
         "04:Attributes: $label"   => '',
  };	
 
 
  return $zmenu;
}

1;
### Contact: Beth Pritchard bp1@sanger.ac.uk
