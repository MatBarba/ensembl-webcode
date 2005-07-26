package EnsEMBL::Web::Form::Element::String;

use EnsEMBL::Web::Form::Element;
use CGI qw(escapeHTML);
our @ISA = qw( EnsEMBL::Web::Form::Element );

sub _is_valid { return 1; }
sub _extra {
  my $self =shift;
  return sprintf(qq(size="%s" class="%s" onKeyUp="check('%s',this,%s)" onChange="check( '%s', this, %s )" ),
    $self->size||20, $self->style , $self->type, $self->required eq 'yes' ? 1 : 0 , $self->type, $self->required eq 'yes' ? 1 : 0
  );
}

sub validate { return 1; }

sub render {
  my $self = shift;
  return sprintf( '%s<input type="%s" name="%s" value="%s" id="%s" %s />%s%s',
    $self->introduction,
    $self->widget_type,
    CGI::escapeHTML( $self->name ),
    CGI::escapeHTML( $self->value ), CGI::escapeHTML( $self->id ),
    $self->_extra(),
    $self->required eq 'yes' ? $self->required_string : '',
    $self->notes
  );
}


1;
