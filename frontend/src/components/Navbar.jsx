import React from 'react';
import { Link, useLocation } from 'react-router-dom';

export default function Navbar() {
    const location = useLocation();
    const path = location.pathname;

    return (
        <nav className="navbar">
            <Link to="/" className="navbar-brand">
                <img src="/favicon.svg" alt="Hea Logo" className="logo-icon" style={{ width: 32, height: 32, objectFit: 'contain', background: 'transparent', boxShadow: 'none' }} />
                <span>Hea</span>
            </Link>

            <ul className="navbar-links">
                <li><Link to="/daily" className={path === '/daily' ? 'active' : ''}>Daily Log</Link></li>
                <li><Link to="/insights" className={path === '/insights' ? 'active' : ''}>Insights</Link></li>
                <li><Link to="/settings" className={path === '/settings' ? 'active' : ''}>Settings</Link></li>
            </ul>

            <Link to="/daily" className="btn btn-primary btn-sm">Log Today</Link>
        </nav>
    );
}
