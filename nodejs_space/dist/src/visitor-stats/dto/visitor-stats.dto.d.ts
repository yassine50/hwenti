export declare class TrackVisitorDto {
    governorateId?: string;
    delegationId?: string;
    latitude?: number;
    longitude?: number;
}
export declare class TrackVisitorResponseDto {
    success: boolean;
}
export declare class GovStatDto {
    governorateId: string;
    governorateName: string;
    governorateNameAr: string;
    governorateNameFr: string;
    count: number;
}
export declare class DelStatDto {
    delegationId: string;
    delegationName: string;
    delegationNameAr: string;
    delegationNameFr: string;
    governorateId: string;
    count: number;
}
export declare class VisitorStatsSummaryResponseDto {
    totalVisitors: number;
    byGovernorate: GovStatDto[];
    byDelegation: DelStatDto[];
}
