=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::Document::Panel::Configurator;

use strict;

use base qw(EnsEMBL::Web::Document::Panel);

sub set_content {
  my ($self, $content) = @_;
  
  $self->{'content'} = qq{
  <div class="panel $self->{'class'}">
    <div class="content">
      $content
    </div>
  </div>};
}

sub _error { my $self = shift; return sprintf '<h1>AJAX error - %s</h1><pre>%s</pre>', @_; }

1;
