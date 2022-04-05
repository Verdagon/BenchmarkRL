using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;

namespace BenchmarkRL {
  interface ICar { }

  interface IHonda : ICar { }
  interface IToyota : ICar { }
  interface ISedan : ICar { }
  interface ISuv : ICar { }
  interface IFossilFuel : ICar { }
  interface IElectric : ICar {
    int getCharge();
  }

  class Clarity : IHonda, ISedan, IElectric {
    public int getCharge() {
      return 1;
    }
  }
  class Civic : IHonda, ISedan, IFossilFuel { }
  class SuvE : IHonda, ISuv, IElectric { 
    public int getCharge() {
      return 2;
    }
    
  }
  class Crv : IHonda, ISuv, IFossilFuel { }
  class Mirai : IToyota, ISedan, IElectric { 
    public int getCharge() {
      return 4;
    }
  }
  class Camry : IToyota, ISedan, IFossilFuel { }
  class BZ4X : IToyota, ISuv, IElectric { 
    public int getCharge() {
      return 8;
    }
  }
  class Highlander : IToyota, ISuv, IFossilFuel { }
  
  internal class Program {
    private static void MyAssert(bool condition) {
      if (!condition) {
        throw new Exception();
      }
    }
    
    public static void Main(string[] args) {
      var blueprint =
          new Taxonomy<ICar>(
              new List<Type> {
                  typeof(Clarity),
                  typeof(Civic),
                  typeof(SuvE),
                  typeof(Crv),
                  typeof(Mirai),
                  typeof(Camry),
                  typeof(BZ4X),
                  typeof(Highlander)
              });
      var bunch = new TypeIndexedDictionary<ICar, int>(blueprint);
      bunch.Add(1, new Clarity());
      bunch.Add(2, new Civic());
      bunch.Add(3, new SuvE());
      bunch.Add(4, new Crv());
      bunch.Add(5, new Mirai());
      bunch.Add(6, new Camry());
      bunch.Add(7, new BZ4X());
      bunch.Add(8, new Highlander());
      
      MyAssert(bunch.FindAll<IHonda>().ToList().Count == 4);
      MyAssert(bunch.FindAll<IToyota>().ToList().Count == 4);
      MyAssert(bunch.FindAll<ISedan>().ToList().Count == 4);
      MyAssert(bunch.FindAll<ISuv>().ToList().Count == 4);
      MyAssert(bunch.FindAll<IElectric>().ToList().Count == 4);
      MyAssert(bunch.FindAll<IFossilFuel>().ToList().Count == 4);

      int totalCharge = 0;
      foreach (var entry in bunch.FindAll<IElectric>()) {
        totalCharge += entry.Value.getCharge();
      }
      MyAssert(totalCharge == 15);
      
      bunch.Remove(1);
      bunch.Remove(2);
      bunch.Remove(3);
      bunch.Remove(4);
      bunch.Remove(5);
      bunch.Remove(6);
      bunch.Remove(7);
      bunch.Remove(8);
    }
  }
}
