package EnsEMBL::Web::Factory::Feature;
                                                                                   
use strict;
use warnings;
no warnings "uninitialized";
                                                                                   
use EnsEMBL::Web::Factory;
use EnsEMBL::Web::Proxy::Object;
                                                                                   
our @ISA = qw(  EnsEMBL::Web::Factory );

#use Bio::SeqIO;
#use Bio::Seq;
#use IO::String;

sub createObjects { 
  my $self   = shift;
  my $feature_type  = $self->param('type') || 'AffyProbe';
  my $create_method = "create_$feature_type";

warn "Trying to use method $create_method";
  
  my ($identifier, $fetch_call, $featureobj, $dataobject);
  my $db        = $self->param('db')  || 'core';

  $featureobj    = $self->$create_method($db);
  $dataobject    = EnsEMBL::Web::Proxy::Object->new( 'Feature', $featureobj, $self->__data );

  if( $dataobject ) {
    $dataobject->feature_type( $feature_type );
    $dataobject->feature_id( $self->param( 'id' ));
    $self->DataObjects( $dataobject );
  }
  
}

#---------------------------------------------------------------------------

sub create_AffyProbe {
  return $_[0]->_generic_create( 'AffyProbe', 'fetch_all_by_probeset', $_[1] );
}
sub create_DnaAlignFeature {
  return $_[0]->_generic_create( 'DnaAlignFeature', 'fetch_all_by_hit_name', $_[1] ); 
}
sub create_ProteinAlignFeature {
  return $_[0]->_generic_create( 'ProteinAlignFeature', 'fetch_all_by_hit_name', $_[1] );
}
sub create_Gene {
  return $_[0]->_generic_create( 'Gene', 'fetch_all_by_external_name', $_[1] ); 
}
sub create_Disease {
  my( $self, $db ) = @_; # Don't need db...
  my $disease_db = $self->database( 'disease' );
  return $self->problem( 'Fatal', 'Database Error', 'No disease database for this species' ) unless $disease_db;
  
  my $EXTRA = join '', map { s/'/\'/g; " and ( d.disease like '%$_%' or g.omim_id='$_' )" } split /\s+/, $self->param('id');
  my $sth = $disease_db->_db_handle->prepare(
    "select distinct d.id, d.disease, g.omim_id, g.chromosome, g.start_cyto, g.end_cyto, g.gene_symbol
       from gene as g, disease as d
      where d.id = g.id $EXTRA"
  );
  $sth->execute;
  my %T ;
  my %gene_symbols;
  foreach my $row ( @{$sth->fetchall_arrayref} ) {
    push @{$T{$row->[6]}}, $row;
    $gene_symbols{$row->[6]}=1;
  } 
  my $features = $self->_generic_create( 'Gene', 'fetch_all_by_external_name',
                                         'core' , join( ' ', keys %gene_symbols) );
  return unless $features;
  my @dis_features = ();
  foreach my $F ( @$features ) {
    warn $F->external_name,' ',$F->{_id_};
    foreach( @{$T{$F->{_id_}}||[]} ) {
      delete $gene_symbols{$F->{_id_}};
      my $NF = {
        'gene'    => $F,
        'disease' => $_->[1],
        'omim_id' => $_->[2],
        'genename' => $F->{_id_},
        'cyto'    => $_->[3].$_->[4].($_->[4] eq $_->[5] ? "" : "-$_->[3]$_->[5]"),
        'gsi'     => $F->stable_id
      };
      push @dis_features, $NF;
    }
  }
  foreach ( keys %gene_symbols ) {
    foreach my $row ( @{$T{$_}} ) {
    push @dis_features, {
     'genename' => $row->[6], 'disease' => $row->[1],
            'omim_id' => $row->[2],
            'gsi'  => '',
            'cyto' => $row->[3].$row->[4].($row->[4] eq $row->[5] ? '' : "-$row->[3]$row->[5]")
    };
    }
  }
  warn @dis_features;
  return \@dis_features;
}

sub _generic_create {
  my( $self, $object_type, $accessor, $db, $id ) = @_;
  $db ||= 'core';
                                                                                   
  $id ||= $self->param( 'id' );
  
  if( !$id ) {
    return undef; # return empty object if no id
  }
  else {
    # Get the 'central' database (core, est, vega)
    my $db_adaptor  = $self->database(lc($db));
    unless( $db_adaptor ){
      $self->problem( 'Fatal', 'Database Error', "Could not connect to the $db database." );
      return undef;
    }
    my $adaptor_name = "get_${object_type}Adaptor";
    my $features = [];
    foreach my $fid ( split /\s+/, $id ) {
      my $t_features;
      eval {
         $t_features = $db_adaptor->$adaptor_name->$accessor($fid);
      };
      if( $t_features ) {
        foreach( @$t_features ) { $_->{'_id_'} = $fid; }
        push @$features, @$t_features;
      }
    }
                                                                                   
    return $features if $features && @$features; # Return if we have at least one feature
    # We have no features so return an error....
    $self->problem( 'no_match', 'Invalid Identifier', "$object_type $id was not found" );
    return undef;
  }

}

1;

