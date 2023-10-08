export declare const PBKDF_ITERATIONS = 100000;
export declare function isBasicSeed(entropy: ArrayBuffer): Promise<boolean>;
export declare function isPasswordSeed(entropy: ArrayBuffer): Promise<boolean>;
export declare function mnemonicToEntropy(mnemonicArray: string[], password?: string): Promise<ArrayBuffer>;
export declare function pbkdf2Sha512(key: ArrayBuffer, salt: string, iterations: number): Promise<Uint8Array>;
export declare function hmacSha512(phrase: string, password: string): Promise<ArrayBuffer>;
export declare function stringToIntArray(str: string, size?: number): Uint8Array;
