 /*object camisetaDeAgus {
   var cantidadDeMasa = 150
   method calorias() = cantidadDeMasa * 15
   method comerBocado(cantidad){
      cantidadDeMasa = (cantidadDeMasa - cantidad).max(0)
   }
 }*/
 
 class Galleta{
   var cantidadDeMasa 
   // Este es el constructor en Java
  //  public Galleta(estaCocida,cantidadDeMasa){
  //   this.estaCocida = estaCocida
  //   this.cantidadDeMasa = cantidadDeMasa
  //  }
   method calorias() = cantidadDeMasa * 15
   method comerBocado(cantidad){
      cantidadDeMasa = (cantidadDeMasa - cantidad).max(0)
   }
}

const unaGalletita = new Galleta(cantidadDeMasa=50)
const otraGalletita = new Galleta(cantidadDeMasa=200)