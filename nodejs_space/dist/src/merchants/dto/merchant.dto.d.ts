export declare class MerchantSetupDto {
    shopName: string;
    tradeType: string;
    governorateId: string;
    delegationId: string;
    phone: string;
    logoFileId?: string;
}
export declare class MerchantUpdateDto {
    shopName?: string;
    tradeType?: string;
    governorateId?: string;
    delegationId?: string;
    phone?: string;
    logoFileId?: string;
}
export declare class MerchantResponseDto {
    id: string;
    userId: string;
    shopName: string | null;
    tradeType: string | null;
    governorateId: string | null;
    governorateName: string | null;
    governorateNameAr: string | null;
    governorateNameFr: string | null;
    delegationId: string | null;
    delegationName: string | null;
    delegationNameAr: string | null;
    delegationNameFr: string | null;
    phone: string | null;
    logoFileId: string | null;
    logoUrl: string | null;
    averageRating: number;
    ratingCount: number;
    setupComplete: boolean;
    createdAt: string;
}
export declare class MerchantListItemDto {
    id: string;
    userId: string;
    shopName: string | null;
    tradeType: string | null;
    governorateName: string | null;
    governorateNameAr: string | null;
    governorateNameFr: string | null;
    delegationName: string | null;
    delegationNameAr: string | null;
    delegationNameFr: string | null;
    logoFileId: string | null;
    logoUrl: string | null;
    averageRating: number;
    ratingCount: number;
}
export declare class MerchantListResponseDto {
    items: MerchantListItemDto[];
    total: number;
    page: number;
    totalPages: number;
}
