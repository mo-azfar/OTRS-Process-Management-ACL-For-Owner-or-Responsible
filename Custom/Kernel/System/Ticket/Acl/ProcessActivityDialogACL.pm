# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
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
    my $ACLName = 'ACLPM_'.$Param{Config}->{Name};
    
    #For Process id filtering
    my $PID = $Param{Config}->{PropertiesProcessEntityID};
    
    #For activity id filtering
    my $AID = $Param{Config}->{PropertiesActivityEntityID};
 
    #For activity dialog id owner view
    my $OWNER_ADID = $Param{Config}->{OwnerActivityDialogEntityID};
    my @OWNER_ADIDs = split /;/, $OWNER_ADID;
    
    #For activity dialog id resposible view
    my $RESPONSIBLE_ADID = $Param{Config}->{ResponsibleActivityDialogEntityID};
    my @RESPONSIBLE_ADIDs = split /;/, $RESPONSIBLE_ADID;
    
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

            # return possible options (black list)
            Possible => {

                # possible ticket options (black list)
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

            # return possible options (black list)
            Possible => {

                # possible ticket options (black list)
                ActivityDialog => [@RESPONSIBLE_ADIDs],
            },
        };
        
        }
    }
    

    return 1;
}

1;
