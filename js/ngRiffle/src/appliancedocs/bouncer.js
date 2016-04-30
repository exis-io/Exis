/**
 * @memberof $riffle
 * @function xsBouncer
 * @description Creates a new {@link Bouncer} class using the given properly formed {@link RiffleDomain}.
 * @returns {Bouncer} A new Bouncer object that can be used for interacting with a {@link /docs/appliances/Bouncer Bouncer} Appliance.
 * @example
 *
 * //create a Bouncer instance from the domain
 * var bouncer = $riffle.xsBouncer();
 *
 * //assign a user to the user role for the app
 * bouncer.assignRole('user', app.getName(), 'xs.demo.dev.app.username' ).then(success, error);  
 *
 */

/**
 * @typedef Bouncer
 * @description The Bouncer class provides an API for interacting with the {@link /docs/appliances/Bouncer Bouncer} Appliance
 * @see {@link /docs/appliances/Bouncer here} for documentation.
 * @example
 * //create a Bouncer instance from the domain
 * var bouncer = $riffle.xsBouncer();
 *
 * //create a static role
 * bouncer.addStaticRole('admin', app.getName());
 */

