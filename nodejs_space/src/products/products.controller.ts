import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard, OptionalJwtAuthGuard } from '../auth/jwt-auth.guard';
import { ProductsService } from './products.service';
import { CreateProductDto, UpdateProductDto, ProductDetailResponseDto, ProductListResponseDto, ViewCountResponseDto, SuccessResponseDto } from './dto/product.dto';

@Controller('api/products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Body() dto: CreateProductDto, @Req() req: Request): Promise<ProductDetailResponseDto> {
    const user = req.user as { id: string };
    return this.productsService.create(user.id, dto);
  }

  @Get('mine')
  @UseGuards(JwtAuthGuard)
  async findMine(
    @Req() req: Request,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<ProductListResponseDto> {
    const user = req.user as { id: string };
    return this.productsService.findMine(user.id, page, limit);
  }

  @Get()
  @UseGuards(OptionalJwtAuthGuard)
  async findAll(
    @Req() req: Request,
    @Query('governorateId') governorateId?: string,
    @Query('delegationId') delegationId?: string,
    @Query('tradeType') tradeType?: string,
    @Query('merchantId') merchantId?: string,
    @Query('search') search?: string,
    @Query('available') available?: string,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<ProductListResponseDto> {
    const user = req.user as { id: string } | null;
    return this.productsService.findAll(
      { governorateId, delegationId, tradeType, merchantId, search, available, page, limit },
      user?.id ?? null,
    );
  }

  @Get(':id')
  @UseGuards(OptionalJwtAuthGuard)
  async findOne(@Param('id') id: string, @Req() req: Request): Promise<ProductDetailResponseDto> {
    const user = req.user as { id: string } | null;
    return this.productsService.findOne(id, user?.id ?? null);
  }

  @Post(':id/view')
  async incrementView(@Param('id') id: string): Promise<ViewCountResponseDto> {
    return this.productsService.incrementView(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(@Param('id') id: string, @Body() dto: UpdateProductDto, @Req() req: Request): Promise<ProductDetailResponseDto> {
    const user = req.user as { id: string };
    return this.productsService.update(id, user.id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async remove(@Param('id') id: string, @Req() req: Request): Promise<SuccessResponseDto> {
    const user = req.user as { id: string };
    return this.productsService.remove(id, user.id);
  }
}
