###########################################################################
# whatbot/Database/Table/Factoid.pm
###########################################################################
# Provides a basic data soup
###########################################################################
# the whatbot project - http://www.whatbot.org
###########################################################################

package whatbot::Database::Table::Soup;
use Moose;
extends 'whatbot::Database::Table';

has 'module' => ( is => 'rw', isa => 'whatbot::Database::Table' );

sub BUILD {
    my ( $self ) = @_;
    
    $self->init_table({
        'name'        => 'soup',
        'primary_key' => 'soup_id',
        'indexed'     => [ 'module_id', 'subject' ],
        'columns'     => {
            'soup_id' => {
                'type'  => 'integer',
            },
            'module_id' => {
                'type'  => 'integer',
            },
            'subject' => {
                'type'  => 'varchar',
                'size'  => 255
            },
            'value' => {
                'type'  => 'text'
            }
        }
    });
    my $module = whatbot::Database::Table->new(
        'base_component' => $self->parent->base_component
    );
    $module->init_table({
        'name'        => 'soup_module',
        'primary_key' => 'module_id',
        'indexed'     => ['name'],
        'columns'     => {
            'module_id' => {
                'type'  => 'integer'
            },
            'name' => {
                'type'  => 'varchar',
                'size'  => 255
            },
        }
    });
    $self->module($module);
}

sub _get_module {
    my ( $self, $caller ) = @_;
    
    my $module = $self->module->search_one({
        'name' => $caller
    });
    if ($module) {
        return $module->module_id;
    } else {
        $module = $self->module->create({
            'name' => $caller
        });
        return $module->module_id;
    }
    
    return;
}

sub set {
    my ( $self, $key, $value ) = @_;
    
    my $row = $self->search_one({
        'module_id' => $self->_get_module( caller() ),
        'subject'   => $key
    });
    if ($row) {
        $row->value($value);
        $row->save();
    } else {
        $row = $self->create({
            'module_id' => $self->_get_module( caller() ),
            'subject'   => $key,
            'value'     => $value
        });
    }
    
    return $row->value;
}

sub get {
    my ( $self, $key ) = @_;
    
    my $row = $self->search_one({
        'module_id' => $self->_get_module( caller() ),
        'subject'   => $key
    });
    if ($row) {
        return $row->value;
    }
    return;
}

sub clear {
	my ( $self, $key ) = @_;
    
    my $row = $self->search_one({
        'module_id' => $self->_get_module( caller() ),
        'subject'   => $key
    });
    if ($row) {
        $row->delete;
    }
    return;
}

sub get_hashref {
    my ( $self ) = @_;
    
    my $rows = $self->search({
        'module_id' => $self->_get_module( caller() )
    });
    my %results;
    foreach my $row (@$rows) {
    	$results{ $row->subject } = $row->value;
    }

    return \%results;
}

1;

=pod

=head1 NAME

whatbot::Database::Table::Soup - Allows commands access to a data "soup".

=head1 SYNOPSIS

 use whatbot::Database::Table::Soup;

=head1 DESCRIPTION

whatbot::Database::Table::Soup allows commands to have access to a data "soup". This
provides simple key->value database support to commands that don't require
multiple column relationships. Handy for preferences, or simple data point
updates. Auto handles update-or-create, expunging entries, etc.

=head1 METHODS

=over 4

=item set( $key, $value )

Set a key/value pair. Auto creates an entry if it doesn't exist, or updates
the existing entry.

=item get( $key )

Get a value for the specified key. Returns undef if the key doesn't exist in
the database.

=item get_hashref()

Get all pairs for the current module. Returns a hashref of the key-value pairs.

=back

=head1 INHERITANCE

=over 4

=item whatbot::Component

=over 4

=item whatbot::Database::Table

=over 4

=item whatbot::Database::Table::Soup

=back

=back

=back

=head1 LICENSE/COPYRIGHT

Be excellent to each other and party on, dudes.

=cut
