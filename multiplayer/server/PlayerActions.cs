using Mmorpg.Network;
using Action = Mmorpg.Network.ClientMessage.PayloadOneofCase;

namespace Server;

internal static class PlayerActions {
    internal static bool Allow(ClientMessage message) => message.PayloadCase switch {
        Action.WorldChangeRequest => message.WorldChangeRequest.ValidateTeleport,
        Action.RequestMovement => !message.RequestMovement.HasAttackType || message.RequestMovement.AttackType == (int)AttackType.NoInterrupt,
        Action.PlayerAttackedMonsterRequest => message.PlayerAttackedMonsterRequest.AttackType == (int)AttackType.NoInterrupt,
        Action.PlayerAttackedPlayerRequest => message.PlayerAttackedPlayerRequest.AttackType == (int)AttackType.NoInterrupt,
        Action.TownRequest or Action.SpendAttributePoint or Action.PingRequest or Action.LogoutRequest or Action.LogoutCancelledRequest or
        Action.PlayerMovementStateChangeRequest or Action.PlayerAttackModeChangeRequest or
        Action.ChangePlayerIdleDirectionRequest or Action.PlayerPickupRequested or
        Action.PlayerResurrectedRequest or Action.PlayerBowStanceRequested or
        Action.MoveItemInBagRequest or Action.EquipItemRequest or Action.UnequipItemRequest or
        Action.ConsumeItemRequest or Action.ChangePlayerAppearanceRequest or Action.PlayerItemDropRequested or
        Action.PlayerItemPickupRequested or Action.ChatMessageSendRequest or
        Action.SpellCastStartRequest or Action.SpellCastCancelRequest or Action.SpellCastRequest => true,
        _ => false
    };
}
