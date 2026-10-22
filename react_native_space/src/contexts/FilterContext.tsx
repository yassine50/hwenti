import React, { createContext, useContext, useState, useCallback } from 'react';

interface FilterState {
  governorateId: string | null;
  governorateName: string | null;
  delegationId: string | null;
  delegationName: string | null;
  tradeType: string | null;
  merchantId: string | null;
  merchantName: string | null;
  searchQuery: string;
}

interface FilterContextType extends FilterState {
  setGovernorate: (id: string | null, name: string | null) => void;
  setDelegation: (id: string | null, name: string | null) => void;
  setTradeType: (type: string | null) => void;
  setMerchant: (id: string | null, name: string | null) => void;
  setSearchQuery: (q: string) => void;
  clearAll: () => void;
}

const initial: FilterState = {
  governorateId: null, governorateName: null,
  delegationId: null, delegationName: null,
  tradeType: null, merchantId: null, merchantName: null,
  searchQuery: '',
};

const FilterContext = createContext<FilterContextType>({
  ...initial,
  setGovernorate: () => {},
  setDelegation: () => {},
  setTradeType: () => {},
  setMerchant: () => {},
  setSearchQuery: () => {},
  clearAll: () => {},
});

export function FilterProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<FilterState>(initial);

  const setGovernorate = useCallback((id: string | null, name: string | null) => {
    setState(s => ({ ...s, governorateId: id, governorateName: name, delegationId: null, delegationName: null }));
  }, []);

  const setDelegation = useCallback((id: string | null, name: string | null) => {
    setState(s => ({ ...s, delegationId: id, delegationName: name }));
  }, []);

  const setTradeType = useCallback((type: string | null) => {
    setState(s => ({ ...s, tradeType: type }));
  }, []);

  const setMerchant = useCallback((id: string | null, name: string | null) => {
    setState(s => ({ ...s, merchantId: id, merchantName: name }));
  }, []);

  const setSearchQuery = useCallback((q: string) => {
    setState(s => ({ ...s, searchQuery: q }));
  }, []);

  const clearAll = useCallback(() => {
    setState(initial);
  }, []);

  return (
    <FilterContext.Provider value={{
      ...state, setGovernorate, setDelegation, setTradeType, setMerchant, setSearchQuery, clearAll,
    }}>
      {children}
    </FilterContext.Provider>
  );
}

export function useFilter() {
  return useContext(FilterContext);
}
