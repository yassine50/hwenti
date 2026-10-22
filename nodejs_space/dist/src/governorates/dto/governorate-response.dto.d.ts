export declare class GovernorateItemDto {
    id: string;
    name: string;
    nameAr: string;
    nameFr: string;
}
export declare class GovernorateListResponseDto {
    items: GovernorateItemDto[];
}
export declare class DelegationItemDto {
    id: string;
    name: string;
    nameAr: string;
    nameFr: string;
    governorateId: string;
}
export declare class DelegationListResponseDto {
    items: DelegationItemDto[];
}
