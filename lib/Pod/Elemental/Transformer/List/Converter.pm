package Pod::Elemental::Transformer::List::Converter;

# ABSTRACT: Convert a list to... something else

use Moose;
use namespace::autoclean;
use Moose::Autobox;

use Pod::Elemental;
use Pod::Elemental::Transformer 0.102361;

with 'Pod::Elemental::Transformer';

# debugging...
#use Smart::Comments;

=attr command

The command we change C<=item> elements to; defaults to C<head2>.

=method command

Accessor to the command attribute.

=cut

has command => (is => 'rw', isa => 'Str', default => 'head2');

=method transform_node($node)

Takes a node, and replaces any C<=item>'s with our target command (by default,
C<=head2>).  We also drop any command elements found for C<=over> and
C<=back>.

=cut

sub transform_node {
    my ($self, $node) = @_;

    my %drop = map { $_ => 1 } qw{ over back };
    my @elements;

    ### get children, and loop over them...
    ELEMENT_LOOP: for my $element ($node->children->flatten) {

        do { push @elements, $element; next ELEMENT_LOOP }
            unless $element->does('Pod::Elemental::Command');

        if ($element->does('Pod::Elemental::Command')) {

            my $command = $element->command;
            next ELEMENT_LOOP if $drop{$command};

            if ($command eq 'item') {

                my $content = $element->content;

                ### $content
                if ($content =~ /^\*\s*$/) {

                    warn 'not handling plain * items yet';
                    next ELEMENT_LOOP;
                }
                elsif ($content =~ /^\*/) {

                    $content =~ s/^\*\s*//;
                }

                chomp $content;
                $element->command($self->command);
                $element->content($content);
            }

            push @elements, $element;
        }
    }

    $node->children([ @elements ]);
    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    # somewhere inside your code...
    my $transformer = Pod::Elemental::Transformer::List::Converter->new;
    $transformer->transform_node($node);

=head1 DESCRIPTION

This L<Pod::Elemental::Transformer> takes a given node's children, and
converts any list commands to another command, C<head2> by default.

That is:

=over 4

=item C<=item> becomes C<=head2>, and

=item C<=over> and <=back> commands are dropped entirely.

=back

As you can imagine, it's important to be selective with the nodes you run
through this transformer -- if you pass the entire document to it, it will
obliterate any lists found.

=head1 SEE ALSO

L<Pod::Elemental::Transformer>
L<Pod::Weaver::Section::Collect::FromOther>

=cut
