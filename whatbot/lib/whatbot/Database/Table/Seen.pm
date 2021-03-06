package whatbot::Database::Table::Seen;
use Moose;
extends 'whatbot::Database::Table';

sub BUILD {
    my ( $self ) = @_;
    
    $self->init_table({
        'name'        => 'seen',
        'primary_key' => 'seen_id',
        'indexed'     => ['user'],
        'defaults'    => {
            'timestamp' => { 'database' => 'now' }
        },
        'columns'     => {
            'seen_id' => {
                'type'  => 'integer'
            },
            'timestamp' => {
                'type'  => 'integer'
            },
            'user' => {
                'type'  => 'varchar',
                'size'  => 255
            },
            'message' => {
                'type'  => 'text'
            }
        }
    });
}

sub seen {
	my ( $self, $user, $message ) = @_;
	
	return unless ($user);
	$user = lc($user);
	
	my $seen_row = $self->search_one({
	    'user' => $user
	});
	if ( defined $message ) {
	    $seen_row->delete() if ( defined $seen_row );
	    return $self->create({
	        'user'      => $user,
	        'message'   => $message
	    });
	}

	return $seen_row;
}

1;

=pod

=head1 NAME

whatbot::Database::Table::Seen - Database model for seen

=head1 SYNOPSIS

 use whatbot::Database::Table::Seen;

=head1 DESCRIPTION

whatbot::Database::Table::Seen does stuff.

=head1 METHODS

=over 4

=item set( $key, $value )

Set a key/value pair. Auto creates an entry if it doesn't exist, or updates
the existing entry.

=item get( $key )

Get a value for the specified key. Returns undef if the key doesn't exist in
the database.

=back

=head1 INHERITANCE

=over 4

=item whatbot::Component

=over 4

=item whatbot::Database::Table

=over 4

=item whatbot::Database::Table::Seen

=back

=back

=back

=head1 LICENSE/COPYRIGHT

Be excellent to each other and party on, dudes.

=cut
