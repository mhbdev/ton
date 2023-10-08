export interface KeyPair {
    publicKey: Uint8Array;
    secretKey: Uint8Array;
}
export declare function mnemonicToKeyPair(mnemonicArray: string[], password?: string): Promise<KeyPair>;
