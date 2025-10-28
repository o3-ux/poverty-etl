import React, { useState } from 'react';
import EligibilityForm from './EligibilityForm';
import ProgramList from './ProgramList';
import programs from './programs.json';
import './App.css';

function App() {
  const [eligiblePrograms, setEligiblePrograms] = useState([]);
  
  const handleEligibilityResult = (eligibleProgramIds) => {
    const filtered = programs.filter(program => 
      eligibleProgramIds.includes(program.program_id)
    );
    setEligiblePrograms(filtered);
  };

  return (
    <div className="container-fluid py-4">
      <div className="row justify-content-center">
        <div className="col-lg-10">
          <nav className="navbar navbar-expand-lg navbar-light bg-light mb-4 shadow-sm">
            <div className="container-fluid">
              <a className="navbar-brand" href="#">Global Poverty Programs</a>
              <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span className="navbar-toggler-icon"></span>
              </button>
              <div className="collapse navbar-collapse" id="navbarNav">
                <ul className="navbar-nav ms-auto">
                  <li className="nav-item dropdown">
                    <a className="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                      Filter by Country
                    </a>
                    <ul className="dropdown-menu">
                      <li><a className="dropdown-item" href="#">All Countries</a></li>
                      <li><a className="dropdown-item" href="#">United States</a></li>
                      <li><a className="dropdown-item" href="#">India</a></li>
                      <li><a className="dropdown-item" href="#">Brazil</a></li>
                      <li><a className="dropdown-item" href="#">Nigeria</a></li>
                      <li><a className="dropdown-item" href="#">Kenya</a></li>
                      <li><a className="dropdown-item" href="#">Indonesia</a></li>
                    </ul>
                  </li>
                </ul>
              </div>
            </div>
          </nav>
          
          <EligibilityForm onResult={handleEligibilityResult} />
          
          <ProgramList programs={eligiblePrograms} />
        </div>
      </div>
    </div>
  );
}

export default App;

