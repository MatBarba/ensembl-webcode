package EnsEMBL::Web::Form::Element::DropDownAndString;

#--------------------------------------------------------------------
# Creates a form element for an option set, as either a select box
# or a set of radio buttons
# Takes an array of anonymous hashes, thus:
# my @values = (
#           {'name'=>'Option 1', 'value'=>'1'},
#           {'name'=>'Option 2', 'value'=>'2'},
#   );
# The 'name' element is displayed as a label or in the dropdown,
# whilst the 'value' element is passed as a form variable
#--------------------------------------------------------------------

use EnsEMBL::Web::Form::Element;
use CGI qw(escapeHTML);
our @ISA = qw( EnsEMBL::Web::Form::Element );

sub new {
  my $class = shift;
  my %params = @_;
  my $self = $class->SUPER::new(
    %params,
    'render_as' => $params{'select'} ? 'select' : 'radiobutton'
  );
  $self->string_value = $params{'string_value'};
  $self->string_name  = $params{'string_name'};
  $self->string_label = $params{'string_label'};
  return $self;
}

sub _validate() { return $_[0]->render_as eq 'select'; }

sub string_name  :lvalue { $_[0]->{'string_name'};  }
sub string_value :lvalue { $_[0]->{'string_value'}; }
sub string_label :lvalue { $_[0]->{'string_label'}; }

sub render {
  my $self = shift;
  if( $self->render_as eq 'select' ) {
    my $options = '';
    foreach my $V ( @{$self->values} ) {
      my %v_hash = %{$V}; 
      $options .= sprintf( qq(<option value="%s"%s>%s</option>\n),
        $v_hash{'value'}, $self->value eq $v_hash{'value'} ? ' selected="selected"' : '', $v_hash{'name'}
      );
    }
    return sprintf( qq(%s<select name="%s" id="%s" class="normal" onChange="check('%s',this,%s)">\n%s</select>
      <input type="text" name="%s" value="%s" id="%s" class="%s" onKeyUp="check('String',this,%s)" onChange="check('String',this,%s)" />%s
    %s),
      $self->introduction,
      CGI::escapeHTML( $self->name ), CGI::escapeHTML( $self->id ),
      $self->type, $self->required eq 'yes'?1:0,
      $options,
      CGI::escapeHTML( $self->string_name ), CGI::escapeHTML( $self->string_value ), CGI::escapeHTML( $self->id.'_string' ), 
      $self->style, $self->required eq 'yes' ? 1 : 0, $self->required eq 'yes' ? 1 : 0,
      $self->required eq 'yes' ? $self->required_string : '',
      $self->notes
    );
  } else {
    $output = '';
    my $K = 0;
    foreach my $V ( @{$self->values} ) {
      $output .= sprintf( qq(    <div class="radiocheck"><input id="%s_%d" class="radio" type="radio" name="%s" value="%s" %s /><label for="%s_%d">%s</label></div>\n),
        CGI::escapeHTML($self->id), $K, CGI::escapeHTML($self->name), CGI::escapeHTML($V['value']),
        $self->value eq $V['value'] ? ' checked="checked"' : '', CGI::escapeHTML($self->id), $K,
        CGI::escapeHTML($V['name'])
      );
      $K++;
    }
    return $self->introduction.$output.
      sprintf( 
        qq(<input type="text" name="%s" value="%s" id="%s" class="%s" onKeyUp="check('String',this,%s)" onChange="check('String',this,%s)" />%s
        $s),
        CGI::escapeHTML( $self->string_name ), CGI::escapeHTML( $self->string_value ), CGI::escapeHTML( $self->id.'_string' ),
        $self->style, $self->required eq 'yes' ? 1 : 0, $self->required eq 'yes' ? 1 : 0,
        $self->required eq 'yes' ? $self->required_string : '', 
        $self->notes
      );
  }
}

sub validate { return 1; }

1;
