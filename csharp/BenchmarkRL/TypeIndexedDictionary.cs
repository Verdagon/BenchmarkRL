using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace BenchmarkRL {
  class Taxonomy<SuperInterface> {
    private Dictionary<Type, List<Type>> middleInterfaceTypeToConcreteTypes;
    private Dictionary<Type, List<Type>> concreteTypeToMiddleInterfaceTypes;

    public Taxonomy(List<Type> concreteTypes) {
      middleInterfaceTypeToConcreteTypes = new Dictionary<Type, List<Type>>();
      concreteTypeToMiddleInterfaceTypes = new Dictionary<Type, List<Type>>();
      
      foreach (var concreteType in concreteTypes) {
        Trace.Assert(concreteType.IsSubclassOf(typeof(SuperInterface)));
        
        foreach (var possibleMiddleInterfaceType in concreteType.GetInterfaces()) {
          if (possibleMiddleInterfaceType == typeof(SuperInterface)) {
            continue;
          }
          if (typeof(SuperInterface).IsAssignableFrom(possibleMiddleInterfaceType)) {
            var middleInterfaceType = possibleMiddleInterfaceType;
            
            // Record that this concreteType is an interface for this middleInterfaceType
            if (!middleInterfaceTypeToConcreteTypes.ContainsKey(middleInterfaceType)) {
              middleInterfaceTypeToConcreteTypes.Add(middleInterfaceType, new List<Type>());
            }
            var concreteTypesForThisMiddleInterfaceType = middleInterfaceTypeToConcreteTypes[middleInterfaceType];
            concreteTypesForThisMiddleInterfaceType.Add(concreteType);
            
            // Record that this middleInterfaceType is an interface for this concreteType
            if (!concreteTypeToMiddleInterfaceTypes.ContainsKey(concreteType)) {
              concreteTypeToMiddleInterfaceTypes.Add(concreteType, new List<Type>());
            }
            var middleInterfaceTypesForThisConcreteType = concreteTypeToMiddleInterfaceTypes[concreteType];
            middleInterfaceTypesForThisConcreteType.Add(middleInterfaceType);
          }
        }
      }
    }

    public IEnumerable<Type> GetMiddleInterfaceTypesForConcreteType<ConcreteType>() where ConcreteType : SuperInterface {
      return concreteTypeToMiddleInterfaceTypes[typeof(ConcreteType)];
    }
    
    public IEnumerable<Type> GetConcreteTypesForMiddleInterfaceType<MiddleInterfaceType>() where MiddleInterfaceType : SuperInterface {
      return middleInterfaceTypeToConcreteTypes[typeof(MiddleInterfaceType)];
    }
  }
  
  class TypeIndexedDictionary<SuperInterface, K>
      where SuperInterface : class {
    
    private readonly Taxonomy<SuperInterface> blueprint;
    private readonly Dictionary<K, SuperInterface> mainDictionary;
    private readonly Dictionary<Type, Dictionary<K, SuperInterface>> typeToConcretes;

    public TypeIndexedDictionary(Taxonomy<SuperInterface> blueprint) {
      this.blueprint = blueprint;
      this.mainDictionary = new Dictionary<K, SuperInterface>();
      this.typeToConcretes = new Dictionary<Type, Dictionary<K, SuperInterface>>();
    }

    public IEnumerable<KeyValuePair<K, MiddleInterface>> FindAll<MiddleInterface>()
        where MiddleInterface : class, SuperInterface {
      foreach (var concreteType in blueprint.GetConcreteTypesForMiddleInterfaceType<MiddleInterface>()) {
        if (typeToConcretes.TryGetValue(concreteType, out var concretes)) {
          foreach (var concrete in concretes) {
            yield return new KeyValuePair<K, MiddleInterface>(concrete.Key, concrete.Value as MiddleInterface);
          }
        }
      }
    }

    public void Add<ConcreteType>(K key, ConcreteType value) where ConcreteType : class, SuperInterface {
      mainDictionary.Add(key, value);
      if (typeToConcretes.TryGetValue(typeof(ConcreteType), out var concretes)) {
        concretes.Add(key, value);
      } else {
        typeToConcretes.Add(typeof(ConcreteType), new Dictionary<K, SuperInterface> { { key, value } });
      }
    }
    
    public void Remove(K key) {
      var obj = mainDictionary[key];
      var concretes = typeToConcretes[obj.GetType()];
      concretes.Remove(key);
      mainDictionary.Remove(key);
    }
  }
}
