// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  /* ── Global prefix — all routes start with /api ── */
  app.setGlobalPrefix('api');

  /* ── CORS ── */
  app.enableCors({
    origin: [process.env.CLIENT_URL, 'http://localhost:5173'],
    credentials: true,
  });

  /* ── Cookies ── */
  app.use(cookieParser());

  /* ── Global validation pipe ── */
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  app.useGlobalFilters(new GlobalExceptionFilter());

  await app.listen(process.env.PORT ?? 5000);
  console.log(`Server running on port ${process.env.PORT ?? 5000}`);
}

void bootstrap();
