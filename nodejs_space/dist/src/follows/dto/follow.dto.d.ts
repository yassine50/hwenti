export declare class FollowSuccessDto {
    success: boolean;
}
export declare class FollowMerchantDto {
    id: string;
    shopName: string | null;
    tradeType: string | null;
    governorateName: string | null;
    governorateNameAr: string | null;
    governorateNameFr: string | null;
    logoFileId: string | null;
    logoUrl: string | null;
}
export declare class FollowItemDto {
    id: string;
    merchant: FollowMerchantDto;
    createdAt: string;
}
export declare class FollowListResponseDto {
    items: FollowItemDto[];
    total: number;
    page: number;
    totalPages: number;
}
