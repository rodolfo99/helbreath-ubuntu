import { Store } from '@tanstack/react-store';

export const connectingDialogStore = new Store<{ isOpen: boolean; creationPoints?: number }>({ isOpen: false });

export function setConnectingDialogOpen(isOpen: boolean) {
    connectingDialogStore.setState(() => ({ isOpen }));
}

export function setCreationPoints(creationPoints: number) {
    connectingDialogStore.setState(() => ({ isOpen: true, creationPoints }));
}
