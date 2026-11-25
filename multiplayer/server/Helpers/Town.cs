using Mmorpg.Network;
using Server.Utils;
using Server.World.Game;

namespace Server.Helpers;

public static class Town {
    private static readonly Dictionary<int, int> General = new() {
        [128] = 1, [134] = 1, [127] = 2, [36] = 2, [165] = 3, [52] = 3, [46] = 5, [77] = 6
    };
    private static readonly Dictionary<int, int> Smith = new() {
        [3] = 5, [7] = 4, [130] = 6, [53] = 10, [129] = 8, [131] = 16, [133] = 35, [155] = 30
    };
    private static string Service(string id) => id switch {
        "aresden" or "elvine" => "city",
        "areshop" or "elvshop" => "shop",
        "arebsmith" or "elvbsmith" => "smith",
        "arewzdtwr" or "elvwzdtwr" => "magic",
        "arewrus" or "elvwrus" or "arebank2" or "elvbank2" => "bank",
        _ => ""
    };
    private static string Title(string id) => Service(id) switch {
        "city" => "Comercios y rutas",
        "shop" => "Tienda general",
        "smith" => "Herrería",
        "magic" => "Torre de magia",
        "bank" => id.EndsWith("bank2") ? "Banco auxiliar" : "Banco principal",
        _ => ""
    };
    private static IEnumerable<TownOffer> Offers(GameWorldRef wr, GameWorldPlayer p, string service) {
        if (service == "magic") {
            foreach (var spell in wr.SpellsById.Values.OrderBy(s => s.Id)) {
                if (!p.LearnedSpells.Contains(spell.Id)) yield return new TownOffer {
                    Id = spell.Id, Name = spell.Name, Price = 3 + 2 * spell.Id
                };
            }
        } else if (service is "shop" or "smith") {
            foreach (var (id, price) in service == "shop" ? General : Smith) {
                if (wr.ItemsById.TryGetValue(id, out var item)) yield return new TownOffer {
                    Id = id, Name = item.Name, Price = price
                };
            }
        }
    }

    public static void SendState(GameWorldRef wr, GameWorldPlayer p, string notice = "") {
        var service = Service(wr.WorldId);
        if (service == "" && wr.TeleportLocs.Count > 0) service = "routes";
        p.TownTicket = service is "" or "city" or "routes" ? "" : Guid.NewGuid().ToString("N");
        var state = new TownState {
            WorldId = wr.WorldId, Title = service == "routes" ? "Rutas del mapa" : Title(wr.WorldId), Service = service, Ticket = p.TownTicket, Notice = notice
        };
        state.LearnedSpells.AddRange(p.LearnedSpells.Order());
        state.Offers.AddRange(Offers(wr, p, service));
        if (service == "bank") state.Deposits.AddRange(p.BankItems.Select(NetworkManager.ToInventoryItemEntry));
        if (service is "city" or "routes") {
            foreach (var door in wr.TeleportLocs.DistinctBy(d => d.Target.WorldId)) {
                var route = Service(door.Target.WorldId) is "" or "city";
                var loc = door.Locs.First();
                state.Doors.Add(new TownDoor { Name = route ? door.Target.DisplayName : Title(door.Target.WorldId), X = loc.X, Y = loc.Y, Route = route });
            }
        }
        NetworkManager.SendToPlayer(p, new ServerMessage { TownState = state });
    }

    public static void Handle(GameWorldRef wr, GameWorldPlayer p, TownRequest req) {
        if (req.WorldId != wr.WorldId) return;
        if (p.IsDead) { SendState(wr, p, "Resucita para usar este servicio."); return; }
        var service = Service(wr.WorldId);
        if (service == "") return;
        if (req.Action == TownAction.TownBrowse) { SendState(wr, p); return; }
        if (p.TownTicket.Length == 0 || p.TownTicket != req.Ticket) return;
        string notice;
        if (req.Action == TownAction.TownBuy && service is "shop" or "smith" or "magic") {
            var offer = Offers(wr, p, service).FirstOrDefault(o => o.Id == req.OfferId);
            if (offer == null) { SendState(wr, p, "La oferta ya no está disponible."); return; }
            var payment = new InventoryMutationResult();
            if (!p.InventoryManager.TryPayGold(offer.Price, payment)) {
                SendState(wr, p, "Te falta oro en la bolsa."); return;
            }
            Inventory.ApplyInventoryMutation(wr, p, payment);
            if (service == "magic") {
                p.LearnedSpells.Add(offer.Id);
                notice = $"Aprendiste {offer.Name}.";
            } else {
                // The offer was built from this world's catalog, on the same world worker.
                p.InventoryManager.TryCreateItem(offer.Id, null, out var purchase);
                Inventory.ApplyInventoryMutation(wr, p, purchase);
                notice = $"{offer.Name} está en tu bolsa.";
            }
        } else if (req.Action == TownAction.TownDeposit && service == "bank") {
            if (!p.InventoryManager.TryRemoveItemFromBagForGroundDrop(req.ItemUid, out var item, out var change) || item is null) {
                SendState(wr, p, "El objeto ya no está en la bolsa."); return;
            }
            p.BankItems.Add(item);
            Inventory.ApplyInventoryMutation(wr, p, change);
            notice = "Depósito guardado.";
        } else if (req.Action == TownAction.TownWithdraw && service == "bank") {
            var item = p.BankItems.FirstOrDefault(i => i.ItemUid == req.ItemUid);
            if (item == null) { SendState(wr, p, "El objeto ya no está en el banco."); return; }
            var change = new InventoryMutationResult();
            p.BankItems.Remove(item);
            p.InventoryManager.ReturnBankItem(item, change);
            Inventory.ApplyInventoryMutation(wr, p, change);
            notice = "Retirado a tu bolsa.";
        } else return;
        SendState(wr, p, notice);
    }
}
