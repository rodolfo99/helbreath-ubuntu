using Server.Utils;
using Server.World.Game;

namespace Server.Helpers;

public static class MonsterLoot {
    private sealed record Table(int MinGold, int MaxGold, int ExtraChance, int[] Items);
    private static readonly Table Minor = new(1, 3, 30, [36, 165, 52, 7]);
    private static readonly Table Common = new(3, 7, 45, [36, 165, 3, 46, 77, 130, 129, 143]);
    private static readonly Table Major = new(8, 18, 70, [164, 166, 53, 62, 78, 131, 133, 47, 155]);

    public static void Drop(GameWorldRef wr, GameWorldMonster monster) {
        var table = monster.CatalogMonsterId switch {
            1 or 2 or 3 or 6 => Minor,
            5 or 18 or 33 or 43 or 44 or 46 or 55 or 62 => Major,
            _ => Common
        };
        Place(wr, monster, 35, Random.Shared.Next(table.MinGold, table.MaxGold + 1));
        if (Random.Shared.Next(100) < table.ExtraChance) {
            Place(wr, monster, table.Items[Random.Shared.Next(table.Items.Length)], 1);
        }
    }

    private static void Place(GameWorldRef wr, GameWorldMonster monster, int itemId, int quantity) {
        if (!wr.ItemsById.ContainsKey(itemId)) return;
        var cell = Location.FindNearestFreeLocation(
            (x, y) => wr.OccupancyTracker.IsFreeAndNotTeleportCell(x, y) && wr.GroundStateTracker.HasDropSpace(x, y),
            monster.PosX, monster.PosY, maxRadius: 3);
        if (cell is null) return;
        var item = new InventoryItemState(itemId, InventoryManager.CreateItemUid(), null, null, quantity, 0, null);
        if (wr.GroundStateTracker.TryAddDroppedItem(item, cell.Value.X, cell.Value.Y, out var previous, out var top)) {
            GroundStateVisibility.BroadcastGroundItemTopStateChanged(wr, previous, top);
        }
    }
}
