package Bio::EnsEMBL::GlyphSet::das;
use strict;
use vars qw(@ISA);
use Bio::EnsEMBL::GlyphSet;
@ISA = qw(Bio::EnsEMBL::GlyphSet);
use Bio::EnsEMBL::Glyph::Rect;
use Bio::EnsEMBL::Glyph::Text;
use ExtURL;
use SiteDefs;

sub init_label {
    my ($self) = @_;
    return if( defined $self->{'config'}->{'_no_label'} );
    my $label = new Bio::EnsEMBL::Glyph::Text({
	'text'      => $self->{'extras'}->{'caption'},
	'font'      => 'Small',
	'absolutey' => 1
    });
    $self->label($label);
}

sub _init {
    my ($self) = @_;
    return unless ($self->strand() == -1);
	
    my $Config         	= $self->{'config'};
    my $feature_colour 	= $Config->get($self->das_name(), 'col') || $Config->colourmap()->id_by_name('contigblue1');
    my $vc 		 = $self->{'container'};
    my $red      = $Config->colourmap()->id_by_name('red');
    my ($w,$h)   = $Config->texthelper()->real_px2bp('Tiny');
    my $length   = $vc->length() +1;
    $w *= $length/($length-1);
    
    my @features = $vc->get_all_ExternalFeatures();
    my $link_text = $self->{'extras'}->{'linktext'} || 'Additional info';
	my $ext_url;
	if( $self->{'extras'}->{'linkURL'} ) {
		if($self->{'extras'}->{'name'} =~ /^extdas_/) {
			$ext_url = ExtURL->new(
				$self->{'extras'}->{'linkURL'} => $self->{'extras'}->{'linkURL'}
			);
		} else {
			$ext_url = ExtURL->new();		
		}
	}
	
    my $text = '';
    my $empty_flag =1;
	foreach my $f(@features){
		next unless ($f->primary_tag() eq "das" && $f->source_tag() eq $self->{'extras'}->{'dsn'});
		my $id     = $f->das_id();
        $empty_flag =0;
        ### if there is an error in the retrieval of the DAS source then
        ### a feature with ->id "__ERROR__" is added to the feature list
        ### this forces an error text to be displayed below [ error message is in ->das_id() ]

        if($f->id eq '__ERROR__') {
            $text = 'Error retrieving '.$self->{'extras'}->{'caption'}." features ($id)";
            next;
        }

		my $zmenu = {
                	'caption'         => $self->{'extras'}->{'label'},
                	"DAS source info" => $self->{'extras'}->{'url'}
        };
		# JS5: If we have an ID then we can add this to the Zmenu and
		#      also see if we can make a link to any additional information
		#      about the source.
		if($id && $id ne 'null') {
			if($self->{'extras'}->{'linkURL'}){
				$zmenu->{$link_text} = $ext_url->get_url( $self->{'extras'}->{'linkURL'}, $id );
			}
	    	$zmenu->{$id} = '';
		}
		my $glyph = new Bio::EnsEMBL::Glyph::Rect({
            'x'      	=> $f->start(),
	    	'y'      	=> 0,
	    	'width'  	=> $f->end()-$f->start(),
	    	'height' 	=> 8,
	    	'colour' 	=> $feature_colour,
	    	'absolutey' => 1,
            'zmenu'     => $zmenu
		});
		$self->push($glyph);
    }
    $text = 'No '.$self->{'extras'}->{'caption'}.' features in this region' if($empty_flag);
    unless($text eq '') {
        my $bp_textwidth = $w * length($text);
        my $tglyph = new Bio::EnsEMBL::Glyph::Text({
                'x'         => int(($length - $bp_textwidth)/2),
                'y'         => 0,
    	    	'height' 	=> 8,
                'font'      => 'Tiny',
                'colour'    => $red,
                'text'      => $text,
                'absolutey' => 1,
        });
		$self->push($tglyph);
    }
    
    
        
}

sub das_name {
    my ($self) = @_;
    return $self->{'extras'}->{'name'};
}

1;
