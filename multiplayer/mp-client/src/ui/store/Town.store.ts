import { Store } from '@tanstack/react-store';
import type { TownState } from '../../proto/generated/network';

interface TownUi { room?: TownState; open: boolean; pending: boolean }
export const townStore = new Store<TownUi>({ open: false, pending: false });
export function receiveTown(room?: TownState) {
    townStore.setState(previous => {
        const entered = previous.room?.worldId !== room?.worldId;
        const inside = !!room?.service && room.service !== 'city' && room.service !== 'routes';
        return { room, open: room?.service ? (entered ? inside : previous.open) : false, pending: false };
    });
}
export const showTown = (open: boolean) => townStore.setState(state => ({ ...state, open }));
export const markTownPending = () => townStore.setState(state => ({ ...state, pending: true }));
