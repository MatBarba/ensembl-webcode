package EnsEMBL::Web::Document::Popup;

use strict;
use EnsEMBL::Web::Document::Common;
use EnsEMBL::Web::SpeciesDefs;
our $SD = EnsEMBL::Web::SpeciesDefs->new();

our @ISA = qw(EnsEMBL::Web::Document::Common);

use Data::Dumper qw(Dumper);

sub _initialize_HTML {
  my $self = shift;

## General layout for popup pages...

  $self->add_head_elements qw(
    title      EnsEMBL::Web::Document::HTML::Title
    stylesheet EnsEMBL::Web::Document::HTML::Stylesheet
    javascript EnsEMBL::Web::Document::HTML::Javascript
    meta       EnsEMBL::Web::Document::HTML::Meta
    iehover    EnsEMBL::Web::Document::HTML::IEHoverHack
  );

  $self->add_body_elements qw(
    javascript_div EnsEMBL::Web::Document::HTML::JavascriptDiv
    masthead   EnsEMBL::Web::Document::HTML::MastHead
    close      EnsEMBL::Web::Document::HTML::CloseWindow
    release    EnsEMBL::Web::Document::HTML::Release
    helplink   EnsEMBL::Web::Document::HTML::HelpLink
    html_start EnsEMBL::Web::Document::HTML::HTML_Block
    menu       EnsEMBL::Web::Document::HTML::Menu
    content    EnsEMBL::Web::Document::HTML::Content
    copyright  EnsEMBL::Web::Document::HTML::Copyright
    html_end   EnsEMBL::Web::Document::HTML::HTML_Block
  );

  $self->_common_HTML;
  $self->_script_HTML;
}

1;
