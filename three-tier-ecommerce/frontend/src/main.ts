import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient, provideHttpClient } from '@angular/common/http';
import { bootstrapApplication } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';

interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  emoji: string;
}

interface CartLine {
  product: Product;
  quantity: number;
}

@Component({
  selector: 'shop-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="announcement">Complimentary shipping on orders over $100 <span>✳</span> Thoughtfully made, made to last</div>
    <header class="nav shell">
      <a class="wordmark" href="#top" aria-label="Atelier home">atelier<span>.</span></a>
      <nav aria-label="Main navigation"><a href="#collection">Shop</a><a href="#story">Our approach</a></nav>
      <button class="cart-trigger" (click)="cartOpen = !cartOpen" aria-label="Toggle shopping bag">
        Bag <span class="bag-count">{{ itemCount }}</span>
      </button>
    </header>

    <main id="top">
      <section class="hero shell">
        <div class="hero-copy">
          <span class="eyebrow"><i></i> THE EVERYDAY EDIT · VOL. 04</span>
          <h1>Good things.<br><em>Well chosen.</em></h1>
          <p>A considered collection of useful, beautiful things for the everyday. Made to be reached for, and kept.</p>
          <a class="button dark" href="#collection">Explore the collection <span>↘</span></a>
          <div class="hero-note"><span>01 / 04</span><span>OBJECTS FOR SLOWER LIVING</span></div>
        </div>
        <div class="hero-art" role="img" aria-label="Curated still life of home and travel essentials">
          <div class="sun-disc"></div><div class="art-shape shape-one"></div><div class="art-shape shape-two"></div>
          <div class="art-bag">✳</div><div class="art-caption">THE ART OF<br>THE USEFUL <span>✳</span></div>
          <div class="art-index">FIG. 01 — EVERYDAY ESSENTIALS</div>
        </div>
      </section>

      <section class="promise shell" id="story">
        <div><span class="promise-icon">✳</span><span>Made with intention</span></div>
        <div><span class="promise-icon">↗</span><span>Useful by design</span></div>
        <div><span class="promise-icon">◌</span><span>Fewer, better things</span></div>
      </section>

      <section class="collection shell" id="collection">
        <div class="section-heading"><div><span class="eyebrow">A SMALL, THOUGHTFUL SELECTION</span><h2>Everyday <em>favorites</em></h2></div><span class="item-total">{{ products.length.toString().padStart(2, '0') }} OBJECTS</span></div>
        @if (loading) { <p class="notice">Gathering the good things…</p> }
        @if (error) { <p class="notice error">{{ error }}</p> }
        <div class="product-grid">
          @for (product of products; track product.id; let i = $index) {
            <article class="product-card">
              <div class="product-visual" [class]="'product-visual tone-' + i">
                <span class="product-number">0{{ i + 1 }} / OBJECT</span><span class="product-emoji">{{ product.emoji }}</span>
                <button class="quick-add" (click)="addToBag(product)" [attr.aria-label]="'Add ' + product.name + ' to bag'">+</button>
              </div>
              <div class="product-info"><div><h3>{{ product.name }}</h3><p>{{ product.description }}</p></div><span class="price">{{ product.price | currency }}</span></div>
              <button class="add-link" (click)="addToBag(product)">ADD TO BAG <span>↗</span></button>
            </article>
          }
        </div>
      </section>

      <section class="closing shell"><span class="closing-mark">✳</span><p>Less, but lovely.</p><span>Make room for the things that matter.</span></section>
    </main>

    <footer class="footer shell"><a class="wordmark" href="#top">atelier<span>.</span></a><span>Thoughtful goods for everyday living.</span><span>© ATELIER 2026</span></footer>

    @if (cartOpen) {
      <div class="scrim" (click)="cartOpen = false" (keydown.escape)="cartOpen = false" role="presentation"></div>
      <aside class="cart-panel" aria-label="Shopping bag">
        <div class="cart-heading"><div><span class="eyebrow">YOUR EDIT</span><h2>Shopping bag <em>({{ itemCount }})</em></h2></div><button class="close-cart" (click)="cartOpen = false" aria-label="Close bag">×</button></div>
        @if (cart.length === 0) { <p class="empty-cart">A little room for something lovely.</p> }
        @for (line of cart; track line.product.id) {
          <div class="cart-line"><span class="cart-emoji">{{ line.product.emoji }}</span><div class="cart-line-copy"><strong>{{ line.product.name }}</strong><span>{{ line.product.price | currency }}</span><div class="quantity"><button (click)="changeQuantity(line, -1)" aria-label="Decrease quantity">−</button><span>{{ line.quantity }}</span><button (click)="changeQuantity(line, 1)" aria-label="Increase quantity">+</button></div></div></div>
        }
        @if (cart.length > 0) {
          <div class="cart-bottom"><label>Your name<input [(ngModel)]="customerName" autocomplete="name" placeholder="Alex Morgan"></label><label>Email address<input [(ngModel)]="email" autocomplete="email" type="email" placeholder="alex@example.com"></label><div class="cart-total"><span>Subtotal</span><strong>{{ total | currency }}</strong></div><button class="button dark checkout" (click)="checkout()" [disabled]="submitting">{{ submitting ? 'PLACING ORDER…' : 'PLACE ORDER' }} <span>↗</span></button>@if (checkoutMessage) { <p class="checkout-message">{{ checkoutMessage }}</p> }</div>
        }
      </aside>
    }
  `
})
class StorefrontComponent implements OnInit {
  private readonly http = inject(HttpClient);
  products: Product[] = [];
  cart: CartLine[] = [];
  loading = true;
  error = '';
  cartOpen = false;
  customerName = '';
  email = '';
  submitting = false;
  checkoutMessage = '';

  ngOnInit(): void {
    this.http.get<Product[]>('/api/products').subscribe({
      next: (products) => { this.products = products; this.loading = false; },
      error: () => { this.error = 'The collection is taking a moment to arrive. Please refresh shortly.'; this.loading = false; }
    });
  }

  get itemCount(): number { return this.cart.reduce((count, line) => count + line.quantity, 0); }
  get total(): number { return this.cart.reduce((sum, line) => sum + line.product.price * line.quantity, 0); }

  addToBag(product: Product): void {
    const line = this.cart.find((entry) => entry.product.id === product.id);
    if (line) { line.quantity++; } else { this.cart.push({ product, quantity: 1 }); }
    this.checkoutMessage = '';
    this.cartOpen = true;
  }

  changeQuantity(line: CartLine, change: number): void {
    line.quantity += change;
    if (line.quantity < 1) this.cart = this.cart.filter((entry) => entry !== line);
  }

  checkout(): void {
    if (!this.customerName.trim() || !this.email.includes('@')) {
      this.checkoutMessage = 'Please enter your name and a valid email.';
      return;
    }
    this.submitting = true;
    this.checkoutMessage = '';
    this.http.post<{ id: number; total: number }>('/api/orders', {
      customerName: this.customerName,
      email: this.email,
      items: this.cart.map((line) => ({ productId: line.product.id, quantity: line.quantity }))
    }).subscribe({
      next: (order) => {
        this.checkoutMessage = `Order #${order.id} is in the books. Thank you!`;
        this.cart = [];
        this.submitting = false;
      },
      error: () => {
        this.checkoutMessage = 'We could not place that order. Please try again.';
        this.submitting = false;
      }
    });
  }
}

bootstrapApplication(StorefrontComponent, { providers: [provideHttpClient()] }).catch((error: unknown) => console.error(error));
