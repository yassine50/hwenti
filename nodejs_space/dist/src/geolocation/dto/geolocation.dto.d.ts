export declare class NearestLocationDto {
    latitude: number;
    longitude: number;
}
export declare class GeoGovernorateDto {
    id: string;
    name: string;
    nameAr: string;
    nameFr: string;
}
export declare class GeoDelegationDto {
    id: string;
    name: string;
    nameAr: string;
    nameFr: string;
}
export declare class NearestLocationResponseDto {
    governorate: GeoGovernorateDto;
    delegation: GeoDelegationDto | null;
}
