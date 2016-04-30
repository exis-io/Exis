/**
 * @memberof $riffle
 * @function xsAuth
 * @param {RiffleDomain=} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Auth Auth} appliance. Defaults to the Auth appliance for the app.
 * @description Creates a new {@link Auth} class using the given properly formed {@link RiffleDomain}.
 * @returns {Auth} A new Auth object that can be used for interacting with a {@link /docs/appliances/Auth Auth} Appliance.
 * @example
 * //**Auth Example**
 *
 * //create a Auth instance
 * var auth = $riffle.xsAuth();
 *
 * auth.user_count().then(success, error);  
 *
 */

/**
 * @typedef Auth
 * @description The Auth class provides an API for interacting with an {@link /docs/appliances/Auth Auth} Appliance
 * @see {@link /docs/appliances/Auth here} for documentation.
 * @example
 * **Query Auth Users**
 * //create a Auth instance from the domain
 * var auth = $riffle.xsAuth();
 *
 * //get data about users(email, name, etc.)
 * auth.get_users().then(handler, error);
 */
