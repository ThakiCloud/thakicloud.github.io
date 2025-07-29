// E-commerce product model with search capabilities
export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  category: string;
  tags: string[];
  embedding?: number[];
}

export class ProductRepository {
  private products: Product[] = [];
  
  // Search products using vector similarity
  async searchSimilarProducts(queryEmbedding: number[], limit: number = 10): Promise<Product[]> {
    return this.products
      .filter(product => product.embedding)
      .map(product => ({
        ...product,
        similarity: this.calculateSimilarity(queryEmbedding, product.embedding!)
      }))
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, limit);
  }
  
  private calculateSimilarity(embedding1: number[], embedding2: number[]): number {
    // Cosine similarity calculation
    let dotProduct = 0;
    let norm1 = 0;
    let norm2 = 0;
    
    for (let i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }
    
    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }
  
  // Add product to repository
  async addProduct(product: Product): Promise<void> {
    this.products.push(product);
  }
  
  // Text-based product search
  async searchProductsByText(query: string): Promise<Product[]> {
    const lowerQuery = query.toLowerCase();
    return this.products.filter(product => 
      product.name.toLowerCase().includes(lowerQuery) ||
      product.description.toLowerCase().includes(lowerQuery) ||
      product.tags.some(tag => tag.toLowerCase().includes(lowerQuery))
    );
  }
} 