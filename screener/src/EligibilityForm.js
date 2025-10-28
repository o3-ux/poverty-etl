import React, { useState } from 'react';
import JsonLogic from 'json-logic-js';
import programs from './programs.json';

function EligibilityForm({ onResult }) {
  const [income, setIncome] = useState('');
  const [householdSize, setHouseholdSize] = useState('');
  const [country, setCountry] = useState('');
  
  const handleSubmit = (e) => {
    e.preventDefault();
    
    const data = {
      income: Number(income),
      householdSize: Number(householdSize),
      country: country
    };
    
    const eligibleProgramIds = programs
      .filter(program => {
        if (!program.eligibility_logic) return false;
        try {
          return JsonLogic.apply(program.eligibility_logic, data);
        } catch (error) {
          console.error(`Error applying logic for ${program.program_name}:`, error);
          return false;
        }
      })
      .map(program => program.program_id);
    
    onResult(eligibleProgramIds);
  };
  
  return (
    <form className="p-3 bg-light border rounded mb-4 shadow-sm" onSubmit={handleSubmit}>
      <h2 className="h4 mb-3">Check Your Eligibility</h2>
      <div className="row g-3">
        <div className="col-md-4 mb-3">
          <div className="form-floating">
            <input 
              type="number" 
              className="form-control" 
              id="income" 
              placeholder="Annual Income"
              value={income}
              onChange={(e) => setIncome(e.target.value)}
              required
            />
            <label htmlFor="income">Annual Income</label>
          </div>
        </div>
        <div className="col-md-4 mb-3">
          <div className="form-floating">
            <input 
              type="number" 
              className="form-control" 
              id="householdSize" 
              placeholder="Household Size"
              value={householdSize}
              onChange={(e) => setHouseholdSize(e.target.value)}
              required
            />
            <label htmlFor="householdSize">Household Size</label>
          </div>
        </div>
        <div className="col-md-4 mb-3">
          <div className="form-floating">
            <select
              className="form-select"
              id="country"
              value={country}
              onChange={(e) => setCountry(e.target.value)}
              required
            >
              <option value="">Select a country</option>
              <option value="US">United States</option>
              <option value="IN">India</option>
              <option value="BR">Brazil</option>
              <option value="NG">Nigeria</option>
              <option value="KE">Kenya</option>
              <option value="ID">Indonesia</option>
            </select>
            <label htmlFor="country">Country</label>
          </div>
        </div>
      </div>
      <div className="d-grid gap-2 d-md-flex justify-content-md-end">
        <button type="submit" className="btn btn-primary px-4">Check Eligibility</button>
      </div>
    </form>
  );
}

export default EligibilityForm;

