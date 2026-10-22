import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import type { Request, Response, NextFunction } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({ origin: '*' });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const swaggerPath = 'api-docs';

  // Prevent caching of swagger docs
  app.use(`/${swaggerPath}`, (req: Request, res: Response, next: NextFunction) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.setHeader('Surrogate-Control', 'no-store');
    next();
  });

  const config = new DocumentBuilder()
    .setTitle('Hwenti API')
    .setDescription('\u062d\u0648\u0627\u0646\u062a\u064a - Tunisian Marketplace API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup(swaggerPath, app, document, {
    customSiteTitle: 'Hwenti API',
    customCss: `
      .swagger-ui .topbar { display: none; }
      .swagger-ui { font-family: system-ui, -apple-system, sans-serif; }
      .swagger-ui .info .title { color: #1A1A1A; }
    `,
    swaggerOptions: { layout: 'BaseLayout' },
  });

  await app.listen(process.env.PORT ?? 3333);
}
bootstrap();
