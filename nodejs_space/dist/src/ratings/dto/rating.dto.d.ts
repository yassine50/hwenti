export declare class CreateRatingDto {
    score: number;
}
export declare class RatingResponseDto {
    id: string;
    merchantId: string;
    score: number;
    createdAt: string;
}
export declare class RatingItemDto {
    id: string;
    score: number;
    userName: string;
    createdAt: string;
}
export declare class RatingListResponseDto {
    items: RatingItemDto[];
    average: number;
    total: number;
}
