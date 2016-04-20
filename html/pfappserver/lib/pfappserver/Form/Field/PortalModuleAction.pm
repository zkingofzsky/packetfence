package pfappserver::Form::Field::PortalModuleAction;

=head1 NAME

pfappserver::Form::Field::PortalModuleAction - an action for the portal modules

=head1 DESCRIPTION

This is a compound field that requires only one value of the form
  \d[smhDWMY]

The time unit is rendered using the ButtonGroup widget.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';
use namespace::autoclean;

use pf::config;
use pfconfig::namespaces::config::PortalModules;

has '+do_wrapper' => ( default => 1 );
has '+do_label' => ( default => 1 );
has '+inflate_default_method'=> ( default => sub { \&action_inflate } );
has '+deflate_value_method'=> ( default => sub { \&action_deflate } );
has '+wrapper_class' => (builder => 'action_wrapper_class');

sub action_wrapper_class {[qw(compound-input-btn-group)] }

has_field 'type' =>
  (
   type => 'Select',
   do_label => 0,
   required => 1,
   widget_wrapper => 'None',
   default => 'set_role',
  );
has_field 'arguments' =>
  (
   type => 'Hidden',
   do_label => 0,
   widget_wrapper => 'None',
   element_class => ['input-medium'],
   required => 1,
  );

sub action_inflate {
    my ($self, $value) = @_;
    my $hash = {};
    use pf::log; use Data::Dumper; get_logger->info("HELLOOOOOO");
    if (defined $value) {
        @{$hash}{'type', 'arguments'} = pfconfig::namespaces::config::PortalModules::inflate_action($value);
        $hash->{arguments} = join(',',@{$hash->{arguments}});
    }
    use pf::log; use Data::Dumper; get_logger->info(Dumper($hash));
    return $hash;
}

sub action_deflate {
    my ($self, $value) = @_;
    my $type = $value->{type};
    my $joined_arguments = $value->{arguments};
    return "${type}(${joined_arguments})";
}

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

__PACKAGE__->meta->make_immutable;
1;
