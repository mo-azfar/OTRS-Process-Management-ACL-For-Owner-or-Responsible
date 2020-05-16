# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
package Kernel::System::Ticket::Acl::ProcessActivityDialogACL;

use strict;
use warnings;
use Data::Dumper;

our @ObjectDependencies = (
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Config Acl)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if child tickets are not closed
    return 1 if !$Param{TicketID} || !$Param{UserID};

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    
    # get ticket content
	my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
		UserID        => 1,
		DynamicFields => 0,
		Extended => 0,
    );
	
	return if !%Ticket;
    
    #For generating acl unique name
    my $random = int rand(8888);
    my $ACLName = 'ACLPM_'.$random.'_'.$Param{Config}->{Name};
    
    #For Process id filtering
    my $PID = $Param{Config}->{PropertiesProcessEntityID};
    
    #For activity id filtering
    my $AID = $Param{Config}->{PropertiesActivityEntityID};
 
    #For activity dialog id owner view
    my $OWNER_ADID = $Param{Config}->{PossibleActivityDialogEntityIDOwner};
    my @OWNER_ADIDs = split /;/, $OWNER_ADID;
    
    #For activity dialog id resposible view
    my $RESPONSIBLE_ADID = $Param{Config}->{PossibleActivityDialogEntityIDResponsible};
    my @RESPONSIBLE_ADIDs = split /;/, $RESPONSIBLE_ADID;
    
    #for activity dialog id normal agent view
    my @NORMAL_AGENTS = (@OWNER_ADIDs,@RESPONSIBLE_ADIDs);
    
    my %count;
    $count{ $_ }++ for @NORMAL_AGENTS;
    my @AGENTS = grep { $count{ $_ } == 1 } @NORMAL_AGENTS;
    
    if ( $OWNER_ADID ne "")
    {
        if ( $Param{UserID} eq $Ticket{OwnerID} && $Ticket{OwnerID} ne $Ticket{ResponsibleID} )
        {
        $Param{Acl}->{$ACLName} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
				Process => {
                    ProcessEntityID => [$PID],
					ActivityEntityID => [$AID],
				},
            },

            # return possible options (white list)
            Possible => {

                # possible ticket options (white list)
                ActivityDialog => [@OWNER_ADIDs],
            },
        };
        
        }
    }
    
    if ( $RESPONSIBLE_ADID ne "")
    {
        if ( $Param{UserID} eq $Ticket{ResponsibleID} && $Ticket{ResponsibleID} ne $Ticket{OwnerID} )
        {
        $Param{Acl}->{$ACLName} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
				Process => {
                    ProcessEntityID => [$PID],
					ActivityEntityID => [$AID],
				},
            },

            # return possible options (white list)
            Possible => {

                # possible ticket options (white list)
                ActivityDialog => [@RESPONSIBLE_ADIDs],
            },
        };
        
        }
    }
    
    #for non owner or resposible view
    if ( $Param{UserID} ne $Ticket{ResponsibleID} && $Param{UserID} ne $Ticket{OwnerID} )
    {
        $Param{Acl}->{$ACLName} = {

        # match properties
        Properties => {

            # current ticket match properties
            Ticket => {
                TicketID => [ $Param{TicketID} ],
            },
            Process => {
                ProcessEntityID => [$PID],
                ActivityEntityID => [$AID],
            },
        },

        # return possible not options (black list)
        PossibleNot => {

            # possible not ticket options (black list)
            ActivityDialog => [@AGENTS],
        },
        };
    }

    return 1;
}

1;
