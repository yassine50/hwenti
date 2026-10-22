import type { Request } from 'express';
import { ProductsService } from './products.service';
import { CreateProductDto, UpdateProductDto, ProductDetailResponseDto, ProductListResponseDto, ViewCountResponseDto, SuccessResponseDto } from './dto/product.dto';
export declare class ProductsController {
    private productsService;
    constructor(productsService: ProductsService);
    create(dto: CreateProductDto, req: Request): Promise<ProductDetailResponseDto>;
    findMine(req: Request, page?: number, limit?: number): Promise<ProductListResponseDto>;
    findAll(req: Request, governorateId?: string, delegationId?: string, tradeType?: string, merchantId?: string, search?: string, available?: string, page?: number, limit?: number): Promise<ProductListResponseDto>;
    findOne(id: string, req: Request): Promise<ProductDetailResponseDto>;
    incrementView(id: string): Promise<ViewCountResponseDto>;
    update(id: string, dto: UpdateProductDto, req: Request): Promise<ProductDetailResponseDto>;
    remove(id: string, req: Request): Promise<SuccessResponseDto>;
}
