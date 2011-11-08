# $Id$

package EnsEMBL::Web::Document::Element::Configurator;

# Generates the modal context navigation menu, used in dynamic pages

use strict;

use HTML::Entities qw(encode_entities);

use base qw(EnsEMBL::Web::Document::Element::Content);

sub tree    :lvalue { $_[0]->{'tree'};    }
sub active  :lvalue { $_[0]->{'active'};  }
sub caption :lvalue { $_[0]->{'caption'}; }

sub content {
  my $self = shift;
  
  my $content = $self->{'form'};
  $content   .= $_->component_content for @{$self->{'panels'}};
  $content   .= '</form>' if $self->{'form'};
  
  return $content;
}

sub get_json {
  my $self = shift;
  
  return {
    wrapper   => qq{<div class="modal_wrapper config_wrapper"></div>},
    content   => $self->content,
    params    => { tracks => $self->{'tracks'}, order => $self->{'track_order'} },
    panelType => $self->{'panel_type'}
  };
}

sub init {
  my $self       = shift;
  my $controller = shift;
  my $navigation = $controller->page->navigation;
  
  $self->init_config($controller);
  
  $navigation->tree($self->tree);
  $navigation->active($self->active);
  $navigation->caption($self->caption);
  $navigation->configuration(1);
  
  $self->{'panel_type'} ||= 'Configurator';
}

sub init_config {
  my ($self, $controller, $url) = @_;
  my $hub         = $controller->hub;
  my $action      = $hub->action;
  my $view_config = $hub->get_viewconfig($action);
  
  return unless $view_config;
  
  my $panel        = $self->new_panel('Configurator', $controller, code => 'configurator');
  my $image_config = $view_config->image_config ? $hub->get_imageconfig($view_config->image_config, 'configurator', $hub->species) : undef;
  my ($search_box, $species_select);
  
  $view_config->build_form($controller->object, $image_config);
  
  my $form = $view_config->get_form;
  
  $form->add_element(type => 'Hidden', name => 'component', value => $action, class => 'component');
  
  if ($image_config) {
    if ($image_config->multi_species) {
      foreach (@{$image_config->species_list}) {
        $species_select .= sprintf(
          '<option value="%s"%s>%s</option>', 
          $hub->url('Config', { species => $_->[0], __clear => 1 }), 
          $hub->species eq $_->[0] ? ' selected="selected"' : '',
          $_->[1]
        );
      }
      
      $species_select = qq{<div class="species_select">Species to configure: <select class="species">$species_select</select></div>} if $species_select;
    }
    
    $search_box = qq{<div class="configuration_search"><input class="configuration_search_text" value="Find a track" name="configuration_search_text" /></div>};
    
    $self->active = $image_config->get_parameter('active_menu') || 'active_tracks';
  }
  
  if (!$view_config->tree->get_node($self->active)) {
    my @nodes     = @{$view_config->tree->child_nodes};
    $self->active = undef;
    
    while (!$self->active && scalar @nodes) {
      my $node      = shift @nodes;
      $self->active = $node->id if $node->data->{'class'};
    }
  }
  
  if ($hub->param('partial')) {
    $panel->{'content'}   = join '', map $_->render, @{$form->child_nodes};
    $self->{'panel_type'} = $view_config->{'panel_type'} if $view_config->{'panel_type'};
  } else {
    $panel->set_content($species_select . $search_box . $form->render . $self->save_as($hub->user, $view_config, $view_config->image_config));
  }
  
  $self->add_panel($panel);
  
  $self->tree    = $view_config->tree;
  $self->caption = 'Configure view';
  
  $self->{$_} = $view_config->{$_} || {} for qw(tracks track_order);
  
  $self->add_image_config_notes($controller) if $image_config;
}

sub add_image_config_notes {
  my ($self, $controller) = @_;
  my $panel   = $self->new_panel('Configurator', $controller, code => 'x', class => 'image_config_notes' );
  my $img_url = $self->img_url;
  
  $panel->set_content(qq{
    <div>
      <h2>Key</h2>
      <ul class="configuration_key">
        <li><img src="${img_url}render/normal.gif" /><span>Track style</span></li>
        <li><img src="${img_url}strand-f.png" /><span>Forward strand</span></li>
        <li><img src="${img_url}strand-r.png" /><span>Reverse strand</span></li>
        <li><img src="${img_url}star-on.png" /><span>Favourite track</span></li>
        <li><img src="${img_url}info_blue_17.png" /><span>Track information</span></li>
      </ul>
    </div>
    <div>
      <h4>External tracks</h4>
      <ul class="configuration_key">
        <li><img src="${img_url}track-das.gif" /><span>Distributed Annotation Source</span></li>
        <li><img src="${img_url}track-tmp.gif" /><span>Custom track - uploaded data</span></li>
        <li><img src="${img_url}track-url.gif" /><span>Custom track - UCSC-style web resource</span></li>
        <li><img src="${img_url}track-user.gif" /><span>Custom data saved to your user account</span></li>
      </ul>
    </div>
    <p class="space-below">Please note that the content of external tracks is not the responsibility of the Ensembl project.</p>
    <p>URL-based or DAS tracks may either slow down your ensembl browsing experience OR may be unavailable as these are served and stored from other servers elsewhere on the Internet.</p>
  });

  $self->add_panel($panel);
}

sub save_as {
  my ($self, $user, $view_config, $image_config) = @_;
  
  my $hub  = $self->hub;
  my $data = $hub->config_adaptor->filtered_configs({ code => $image_config ? [ $view_config->code, $image_config ] : $view_config->code, active => '' });
  my ($configs, %seen);
  
  foreach (sort { $a->{'name'} cmp $b->{'name'} } values %$data) {
    next if $seen{$_->{'record_id'}};
    $configs .= sprintf '<option value="%s" class="%s">%s</option>', $_->{'record_id'}, $_->{'record_id'}, $_->{'name'};
    $seen{$_} = 1 for $_->{'record_id'}, $_->{'link_id'};
  }
  
  my $existing = sprintf('
    <div%s>
      <label>Existing configuration:</label>
      <select name="overwrite" class="existing%s">
        <option value="">----------</option>
        %s
      </select>
      <h2>Or</h2>
    </div>',
    $configs ? '' : ' style="display:none"',
    $configs ? '' : ' disabled',
    $configs
  );
  
  my $save_to = $user ? qq{
    <p><label>Save to:</label><span>Account <input type="radio" name="record_type" value="user" class="default" checked /></span><span>Session <input type="radio" name="record_type" value="session" /></span></p>
  } : qq{
    <input type="hidden" name="record_type" value="session" />
  };
  
  return qq{
    <div class="config_save_as">
      <img class="close" src="/i/close.png" alt="close" title="Cancel" />
      <h1>Save configuration</h1>
      <form>
        $existing
        $save_to
        <p><label>Name:</label><input class="name" type="text" name="name" maxlength="255" /></p>
        <p><label>Description:</label><textarea class="desc" name="description" rows="5"/></p>
        <p style="margin-bottom:0"><input class="fbutton disabled" type="button" value="Save" /></p>
      </form>
    </div>
  };
}

1;
