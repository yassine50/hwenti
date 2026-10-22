export declare class AuthUserDto {
    id: string;
    email: string;
    name: string;
    role: string;
    merchantSetupComplete: boolean;
}
export declare class AuthResponseDto {
    token: string;
    user: AuthUserDto;
}
export declare class MeResponseDto {
    user: AuthUserDto;
}
