package cli

import (
	"strconv"

	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/client/flags"
	"github.com/cosmos/cosmos-sdk/client/tx"
	"github.com/spf13/cobra"
	"github.com/trailofbits/incorrect_getsigners/x/incorrectgetsigners/types"
)

var _ = strconv.Itoa(0)

func CmdDelegatePost() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "delegate-post [delegatee] [title] [body]",
		Short: "Broadcast message delegatePost",
		Args:  cobra.ExactArgs(3),
		RunE: func(cmd *cobra.Command, args []string) (err error) {
			argDelegatee := args[0]
			argTitle := args[1]
			argBody := args[2]

			clientCtx, err := client.GetClientTxContext(cmd)
			if err != nil {
				return err
			}

			msg := types.NewMsgDelegatePost(
				clientCtx.GetFromAddress().String(),
				argDelegatee,
				&types.Post{Title: argTitle, Body: argBody},
			)
			if err := msg.ValidateBasic(); err != nil {
				return err
			}
			return tx.GenerateOrBroadcastTxCLI(clientCtx, cmd.Flags(), msg)
		},
	}

	flags.AddTxFlagsToCmd(cmd)

	return cmd
}
