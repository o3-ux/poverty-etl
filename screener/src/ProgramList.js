import React from 'react';

function ProgramList({ programs }) {
  if (!programs || programs.length === 0) {
    return (
      <div className="alert alert-info" role="alert">
        No eligible programs found. Try adjusting your criteria.
      </div>
    );
  }

  return (
    <div>
      <h3 className="h5 mb-3">Eligible Programs ({programs.length})</h3>
      <div className="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        {programs.map(program => (
          <div className="col" key={program.program_id}>
            <div className="card h-100 shadow-sm">
              <div className="card-header bg-light">
                {program.country && (
                  <span className="badge bg-primary me-2">{program.country}</span>
                )}
                {program.digital_implementation_notes && 
                  <span className="badge bg-success">Digital</span>
                }
              </div>
              <div className="card-body">
                <h5 className="card-title">{program.program_name}</h5>
                {program.program_description && (
                  <p className="card-text small text-muted">{program.program_description}</p>
                )}
                {program.helpline && (
                  <p className="card-text small"><strong>Helpline:</strong> {program.helpline}</p>
                )}
                <div className="d-flex justify-content-between align-items-center mt-3">
                  {program.apply_url && (
                    <a href={program.apply_url} className="btn btn-outline-primary btn-sm" target="_blank" rel="noopener noreferrer">
                      Apply Now
                    </a>
                  )}
                  {program.turnaround_time && (
                    <small className="text-muted">{`Processing: ${program.turnaround_time}`}</small>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ProgramList;

