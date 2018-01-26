package pf::UnifiedApi::Controller::Config;

=head1 NAME

pf::UnifiedApi::Controller::Config;

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config

=cut

use strict;
use warnings;
use Mojo::Base qw(pf::UnifiedApi::Controller::RestRoute);

has 'config_store_class';
has 'form_class';

sub list {
    my ($self) = @_;
    my $cs = $self->config_store;
    $self->render(json => {items => $cs->readAll('id')}, status => 200);
}

sub config_store {
    my ($self) = @_;
    $self->config_store_class->new;
}

sub form {
    my ($self, $item) = @_;
    $self->form_class->new;
}

sub resource {
    my ($self) = @_;
    my $id = $self->primary_key;
    my $cs = $self->config_store;
    if (!$cs->hasId($id)) {
        return $self->render_error(404, "Item ($id) not found");
    }
    return 1;
}

sub primary_key {
    my ($self) = @_;
    return $self->stash->{id};
}

sub get {
    my ($self) = @_;
    return $self->render(json => {item => $self->item});
}

sub item {
    my ($self) = @_;
    my $id = $self->primary_key;
    my $cs = $self->config_store;
    my $item = $cs->read($id, 'id');
    return $self->cleanup_item($item);
}

sub cleanup_item {
    my ($self, $item) = @_;
    return $item;
}

sub create {
    my ($self) = @_;
    my ($error, $item) = $self->get_json;
    if (defined $error) {
        return $self->render_error(400, "Bad Request : $error");
    }
    $item = $self->validate_item($item);
    if (!defined $item) {
        return 0;
    }
    my $cs = $self->config_store;
    my $id = $item->{id};
    if ($cs->hasId($id)) {
        return $self->render_error(409, "An attempt to add a duplicate entry was stopped. Entry already exists and should be modified instead of created");
    }
    delete $item->{id};
    $cs->create($id, $item);
    $cs->commit;
    $self->res->headers->location($self->make_location_url($id));
    $self->render(status => 201, text => '');
}

sub validate_item {
    my ($self, $item) = @_;
    my $form = $self->form($item);
    $form->process(posted => 1, params => $item);
    if (!$form->has_errors) {
        return $form->value;
    }
    my $field_errors = $form->field_errors;
    my @errors;
    while (my ($k,$v) = each %$field_errors) {
        push @errors, {$k => $v};
    }
    $self->render_error(417, "Unable to validate", \@errors);
    return undef;
}

sub make_location_url {
    my ($self, $id) = @_;
    my $url = $self->url_for;
    return "$url/$id";
}

sub remove {
    my ($self) = @_;
    my $id = $self->primary_key;
    my $cs = $self->config_store;
    $cs->remove($id, 'id');
    $cs->commit;
    $self->render_empty();
}

sub update {
    my ($self) = @_;
    my $id = $self->primary_key;
    my $item = $self->cleanup_item($self->req->json);
    my $cs = $self->config_store;
    $cs->update($self->primary_key, $self->cleanup_item($self->req->json));
    $cs->commit;
    $self->render(status => 200, json => { message => "$id updated"});
}

sub replace {
    my ($self) = @_;
    return $self->update;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

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

1;

