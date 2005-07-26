package EnsEMBL::Web::Form::Element::MultiSelect;

use EnsEMBL::Web::Form::Element;
use CGI qw(escapeHTML);
our @ISA = qw( EnsEMBL::Web::Form::Element );

sub new {
  my $class = shift;
  my %params = @_;
  my $self = $class->SUPER::new( %params, 'render_as' => $params{'select'} ? 'select' : 'radiobutton', 'values' => $params{'values'} );
  $self->{'class'} = $params{'class'} || 'radiocheck';
  return $self;
}

sub validate { return $_[0]->render_as eq 'select'; }

sub render {
  my $self =shift;
  if( $self->render_as eq 'select' ) {
    my $options = '';
    foreach my $V( @{$self->values} ) {
      $options .= sprintf( "<option value=\"%s\"%s>%s</option>\n",
			   $V->{'value'}, $V->{'checked'} eq 'yes' ? ' selected="selected"' : '', $V->{'name'}
      );
    }
    return sprintf( qq(%s<select multiple="multiple" name="%s" id="%s" class="normal" onChange="check('%s',this,%s)">%s</select>%s),
      $self->introduction,
      CGI::escapeHTML( $self->name ), CGI::escapeHTML( $self->id ),
      $self->type, $self->required eq 'yes'?1:0,
      $options,
      $self->notes
    );
  } else {
    my $output = '';
    my $K = 0;
    foreach my $V ( @{$self->values} ) {
      $output .= sprintf( "    <div class=\"%s\"><input id=\"%s_%d\" class=\"radio\" type=\"checkbox\" name=\"%s\" value=\"%s\" %s/><label for=\"%s_%d\">%s</label></div>\n",
        $self->{'class'},
        CGI::escapeHTML($self->id), $K, CGI::escapeHTML($self->name), CGI::escapeHTML($V->{'value'}),
        $V->{'checked'} eq 'yes' ? ' checked="checked"' : '', CGI::escapeHTML($self->id), $K,
        CGI::escapeHTML($V->{'name'})
      );
      $K++;
    }
    return $self->introduction.$output.$self->notes;
  }
}

1;
